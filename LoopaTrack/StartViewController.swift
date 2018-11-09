import UIKit

class StartViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var serverField: UITextField!
    @IBOutlet weak var startButton: UIButton!
    
    @IBAction func onStart(_ sender: AnyObject) {
        startButton.isEnabled = false

        var urlString = serverField.text!
        if !urlString.hasSuffix("/") {
            urlString += "/"
        }
        urlString += "api/server"
        
        if let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if error == nil {
                    do {
                        try JSONSerialization.jsonObject(with: data!, options: [])
                        DispatchQueue.main.async {
                            self.onSuccess()
                        }
                    } catch _ as NSError {
                        DispatchQueue.main.async {
                            self.onError()
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.onError()
                    }
                }
            }
            task.resume()
        } else {
            self.onError()
        }
    }
    
    override func viewDidLoad() {
        serverField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func onSuccess() {
        UserDefaults.standard.set(serverField.text, forKey: "url")
        performSegue(withIdentifier: "StartSegue", sender: self)
    }
    
    func onError() {
        startButton.isEnabled = true
        
        let alert = UIAlertController(title: "Error", message: "Conexión con el servidor fallida", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default))
        present(alert, animated: true)
    }

}
