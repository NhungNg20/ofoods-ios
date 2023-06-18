//
//  FirebaseController.swift
//  ofoods
//
//  Created by Nhung Nguyen on 3/5/2023.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import FirebaseStorage


class DatabaseController: NSObject, DatabaseProtocol {

    var listeners = MulticastDelegate<DatabaseListener>()
    var database: Firestore
    var fireBaseAuth: Auth

    var recipesRef: CollectionReference?
    var usersRef: CollectionReference?
    var sharedRecipesRef: CollectionReference?
    var recipeImageStoreRef: StorageReference?
    
    var allUsers: [User] = []
    var sharedRecipes: [SharedRecipe] = []
    var currentUser: User?
    var currenUserId: String?
    
    override init() {
        // Configuring firestore references
        FirebaseApp.configure()
        database = Firestore.firestore()
        fireBaseAuth = Auth.auth()
        recipesRef = database.collection("recipes")
        usersRef = database.collection("users")
        sharedRecipesRef = database.collection("shared_recipes")
        recipeImageStoreRef = Storage.storage().reference()
        super.init()
        
        // Only set up listeners once user is logged in
        fireBaseAuth.addStateDidChangeListener { (auth, user) in
            if user != nil {
                self.currenUserId = user?.uid
                Task {
                    self.setUpAllUsersListener()
                    self.setUpRecipesListener()
                    self.setUpSharedRecipesListener()
                }
            }
        }
    }
    
    // MARK: - Listeners
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        listener.onUsersChange(change: .update, users: allUsers)
        
        if listener.listenerType == .sharedRecipeWithUsers {
            listener.onSharedRecipeWithUsersChange(change: .update, sharedRecipes: sharedRecipes)
        }

        if listener.listenerType == .myUser, let currentUser = currentUser {
            listener.onMyUserChange(change: .update, user: currentUser)
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    // Listen to users collection
    func setUpAllUsersListener() {
        usersRef?.addSnapshotListener() {
            (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            self.parseUserSnapshot(snapshot: querySnapshot)
        }
    }
    
    // Parsing the users query
    func parseUserSnapshot(snapshot: QuerySnapshot) {
        var users: [User] = []
        snapshot.documents.forEach { (document) in
            var parsedUser: User?
            
            do {
                parsedUser = try document.data(as: User.self)
            } catch {
                return
            }
            
            guard let user = parsedUser else {
                print("Document doesn't exist")
                return;
            }
            
            // Getting the current user
            if user.id == self.currenUserId {
                self.currentUser = user
                self.listeners.invoke { (listener) in
                    if listener.listenerType == ListenerType.myUser {
                        listener.onMyUserChange(change: .update, user: self.currentUser!)
                    }
                }
            } else {
                users.append(user)
            }
        }
        self.allUsers = users
        self.listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.users {
                listener.onUsersChange(change: .update, users: self.allUsers)
            }
        }
    }
    
    // Listen to recipes of current user
    func setUpRecipesListener() {
        var recipeRefs: [DocumentReference]?
        if let id = currenUserId {
            usersRef?.document(id).addSnapshotListener() { [self]
                (querySnapshot, error) in
                guard let querySnapshot = querySnapshot else {
                    print("Failed to fetch documents with error: \(String(describing: error))")
                    return
                }
                recipeRefs = querySnapshot.data()?["recipes"] as? [DocumentReference] ?? nil
                if let recipeRefs = recipeRefs {
                    // Getting the recipe details
                    parseRecipeReferences(recipeRefs: recipeRefs)
                } else {

                }
            }
        }
    }

    // Getting the recipe details from recipe document references
    func parseRecipeReferences(recipeRefs: [DocumentReference]) {
        var recipeList = [Recipe]()
        let group = DispatchGroup()
        recipeRefs.forEach { ref in
            group.enter()
            ref.getDocument() { (document, error) in
                do {
                    if let recipe = try document?.data(as: Recipe.self) {
                        recipeList.append(recipe)
                        self.loadRecipeImage(recipe: recipe)
                    }
                } catch {
                    print(error)
                }
                group.leave()
            }
        }
        
        // Notify all the listeners interested in recipes of current users
        group.notify(queue: .main) {
            self.listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.myRecipes || listener.listenerType == ListenerType.sharedRecipes {
                    if let recipes = self.currentUser?.recipes, recipes.contains(recipeRefs) == true {
                        listener.onMyRecipesChange(change: .update, recipes: recipeList)
                    } else {
                        listener.onSharedRecipesChange(change: .update, recipes: recipeList)
                    }
                }
            }
        }
    }
    
    // Listen to all shared recipe events
    func setUpSharedRecipesListener() {
        sharedRecipesRef?.addSnapshotListener({ (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            // List of the recipes shared with current user
            var sharedRecipeRefs: [DocumentReference] = []
            // List of all the shared recipe records
            var allSharedRecipes: [SharedRecipe] = []
            
            querySnapshot.documents.forEach({ (document) in
                var parsedRecord: SharedRecipe?

                do {
                    parsedRecord = try document.data(as: SharedRecipe.self)
                } catch {
                    return
                }

                guard let record = parsedRecord, let recipeId = record.recipeId else {
                    print("Document doesn't exist")
                    return;
                }
                
                // Check if the recipe is shared to the current user
                if record.userId == self.currenUserId, let recipeRef = self.recipesRef?.document(recipeId) {
                    sharedRecipeRefs.append(recipeRef)
                }
                allSharedRecipes.append(record)
                
            })
            
            if !allSharedRecipes.isEmpty {
                // Invoke listeners interested in the all shared recipes
                self.sharedRecipes = allSharedRecipes
                self.listeners.invoke { (listener) in
                    if listener.listenerType == ListenerType.sharedRecipeWithUsers {
                        listener.onSharedRecipeWithUsersChange(change: .update, sharedRecipes: allSharedRecipes)
                    }
                }
            }
            // Parse/invoke listeners interested only in the shared recipes of current user
            if !sharedRecipeRefs.isEmpty {
                self.parseRecipeReferences(recipeRefs: sharedRecipeRefs)
            }
        })
    }

    // MARK: - CRUD Operations

    func addNewUser(user: User) -> Bool {
        do {
            if let _ = try usersRef?.document(user.id!).setData(from: user) {
                return true
            }
        } catch {
            return false
        }
        return false
    }
    
    func updateUser(user: User) -> Bool {
        do {
            // Update user authentication
            fireBaseAuth.currentUser?.updateEmail(to: user.email!)
            // Update user record in database
            try usersRef?.document(user.id!).setData(from: user)
            return true
        } catch {
            return false
        }
    }
    
    func updatePassword(newPass: String) {
        fireBaseAuth.currentUser?.updatePassword(to: newPass)
    }

    func shareRecipe(recipeId: String, userId: String) -> Bool {
        let sharedRecipe = SharedRecipe()
        sharedRecipe.recipeId = recipeId
        sharedRecipe.userId = userId

        do {
            if let _ = try sharedRecipesRef?.addDocument(from: sharedRecipe) {
                return true
            }
        } catch {
            return false
        }
        return false
    }
    
    func removeSharing(sharedRecipeId: String) {
        sharedRecipesRef?.document(sharedRecipeId).delete()
    }

    func addRecipe(recipe: Recipe, image: Data?) -> Bool {
        recipe.authorId = currenUserId
        do {
            // Add recipe to recipes collection
            if let recipeRef = try recipesRef?.addDocument(from: recipe) {
                recipe.id = recipeRef.documentID
                if let image = image {
                    savePhoto(data: image, recipeId: recipe.id!)
                }
                // Add recipe reference to user's recipes array
                if let id = currenUserId {
                    usersRef?.document(id).updateData([
                        "recipes" : FieldValue.arrayUnion([recipeRef])
                    ])
                    return true
                }
            }
        } catch {
            return false
        }
        return false
    }
    
    // Saving recipe photo
    func savePhoto(data: Data, recipeId: String) {
        let imageURL = "recipes/\(recipeId).jpg"
        
        // Saving to local storage
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(imageURL)
        
        do {
            try data.write(to: fileURL)
            self.recipesRef?.document("\(recipeId)").updateData(["imageUrl" : imageURL])
        } catch {
            print(error.localizedDescription)
        }
        
        // Saving to Firebase storage
        let imageRef = recipeImageStoreRef?.child(imageURL)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        if let imageRef = imageRef {
            let upload = imageRef.putData(data, metadata: metadata)

            upload.observe(.failure) { snapshot in
                print("Unable to upload image")
            }
        }
    }
    
    // Get the recipe photo
    func loadRecipeImage(recipe: Recipe) {
        if let imageURL = recipe.imageUrl {
            // Getting recipe photo from local storage
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let documentsDirectory = paths[0]
            let fileURL = documentsDirectory.appendingPathComponent(imageURL)
            
            recipe.image = UIImage(contentsOfFile: fileURL.path())
            
            // Check if photo was found locally, if not download from firebase storage
            if recipe.image == nil {
                let download = recipeImageStoreRef?.storage.reference(withPath: imageURL)
                    .write(toFile: fileURL)
                
                download?.observe(.success, handler: { snapshot in
                    recipe.image = UIImage(contentsOfFile: fileURL.path())
                    self.listeners.invoke { (listener) in
                        if listener.listenerType == ListenerType.myRecipes {
                            listener.onImageLoaded(recipe: recipe)
                        }
                    }
                })
                
                download?.observe(.failure) { snapshot in
                    print("\(String(describing: snapshot.error))")
                }
            }
        }
    }

    func updateRecipe(recipe: Recipe, image: Data?) -> Bool {
        do {
            // Update recipe to recipes collection
            try recipesRef?.document(recipe.id!).setData(from: recipe)
            if let image = image {
                savePhoto(data: image, recipeId: recipe.id!)
            }
            // Trigger a recipe update in user's recipes array
            if let recipeDocuRef = getRecipeRefById(id: recipe.id!), let id = currenUserId {
                usersRef?.document(id).updateData([
                    "recipes": FieldValue.arrayRemove([recipeDocuRef])
                ])
                usersRef?.document(id).updateData([
                    "recipes": FieldValue.arrayUnion([recipeDocuRef])
                ])
            }
            return true
        } catch {
            return false
        }
    }
    
    func deleteRecipe(recipe: Recipe) {
        // Only delete the reference if the recipes is not shared
       if sharedRecipes.allSatisfy({ sharedRecipes in
            return sharedRecipes.recipeId != recipe.id
       }) {
           recipesRef?.document(recipe.id!).delete()
           // Deleting the recipe image from firebase
           if let imageURL = recipe.imageUrl {
               recipeImageStoreRef?.child(imageURL).delete { error in
                   print(error?.localizedDescription)
               }
           }
       }
        let recipeDocuRef = getRecipeRefById(id: recipe.id!)
        
        // Delete the recipe ref for user
        if let id = currenUserId {
            usersRef?.document(id).updateData([
                "recipes": FieldValue.arrayRemove([recipeDocuRef])
            ])
        }
        
        // Deleting the recipe image from local storage
        if let imageURL = recipe.imageUrl {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let documentsDirectory = paths[0]
            let fileURL = documentsDirectory.appendingPathComponent(imageURL)
            
            // Checks if file exists, remove if true
            if FileManager.default.fileExists(atPath: fileURL.path) {
                do {
                    try FileManager.default.removeItem(atPath: fileURL.path)
                } catch {
                    print(error.localizedDescription)
                }
                
            }
        }
    }
    
    // Get user recipe reference by recipe id
    func getRecipeRefById(id: String) -> DocumentReference? {
        var recipeRef: DocumentReference?
        currentUser?.recipes?.forEach { ref in
            if ref.documentID == id {
                recipeRef = ref
            }
        }
        return recipeRef
    }
    
}
