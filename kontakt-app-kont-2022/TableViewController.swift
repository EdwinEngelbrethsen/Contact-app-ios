//
//  TableViewController.swift
//  kontakt-app-kont-2022
//


import UIKit
import Contacts
import ContactsUI
import Toast



class TableViewController: UITableViewController,CNContactPickerDelegate, CNContactViewControllerDelegate {
    
    var contacts = [Person]()
    var store: CNContactStore = CNContactStore()
    

    func refeshStore() -> CNContactStore {
        let refresh = CNContactStore()
        
        return refresh
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add, target: self, action: #selector(createContact)
        )
        
        tableView.allowsSelection = true
        tableView.delegate = self
        
        fetchContacts()
    }
    
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?){
        viewController.dismiss(animated: true)
        fetchContacts()
    }

   @objc func createContact() {
            let contactController = CNContactViewController(forNewContact: nil)

            contactController.delegate = self
            contactController.allowsEditing = true
            contactController.allowsActions = true
            contactController.displayedPropertyKeys = [CNContactIdentifierKey, CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey, CNContactBirthdayKey, CNContactImageDataKey]

            contactController.view.layoutIfNeeded()

            present(UINavigationController(rootViewController: contactController), animated:true)
        }

     private func fetchContacts() {
        
        let storeRefresh = refeshStore()
        
        
        storeRefresh.requestAccess(for: .contacts) { (granted, error) in
            if granted {
                let keys = [CNContactIdentifierKey, CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey, CNContactBirthdayKey, CNContactImageDataKey, CNContactImageDataAvailableKey, ]  as [CNKeyDescriptor]
                
                
                let request = CNContactFetchRequest(keysToFetch: keys)
                do {
                    self.contacts.removeAll()
                    try storeRefresh.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                    
                        self.contacts.append(Person(id: contact.identifier ,firstName: contact.givenName, lastName: contact.familyName, tlf: contact.phoneNumbers.first?.value.stringValue ?? "", source: contact))

                    })
                    self.tableView.reloadData()
                } catch let error {
                    print("Failed to enumerate contact", error)
                }
            } else {
                /* https://github.com/scalessec/Toast-Swift */
                self.view.makeToast("Please enable permission in settings to use this app", duration: 30.0, position: .center)
                print(error!)
            }
        }
    }
   

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        
        print(contacts[indexPath.row].firstName)
        
        cell.textLabel?.text = contacts[indexPath.row].firstName + " " + contacts[indexPath.row].lastName
        cell.detailTextLabel?.text = contacts[indexPath.row].tlf

        return cell
    }
    
    
   
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        
        tableView.deselectRow(at: indexPath, animated: true)
        var contactList = contacts[indexPath.row].source
        
        if !contactList.areKeysAvailable([CNContactViewController.descriptorForRequiredKeys()]) {
            do {
                contactList = try self.store.unifiedContact(withIdentifier: contactList.identifier, keysToFetch: [CNContactViewController.descriptorForRequiredKeys()])
            }
            catch { }
        }
        
       
        
        let vc = CNContactViewController(for: contactList)
        
        navigationController?.pushViewController(vc, animated: true)

    }
    
     func contactViewController(viewController: CNContactViewController, didCompleteWithContact contact: CNContact) {
         viewController.dismiss(animated: true, completion: nil)
      }

    func contactViewController(_ viewController: CNContactViewController, shouldPerformDefaultActionFor property: CNContactProperty) -> Bool {
          return true
      }
    
    }


