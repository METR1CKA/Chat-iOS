//
//  ViewController.swift
//  Chat9B
//
//  Created by Igmar Salazar on 10/06/24.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var txfAlias: UITextField!
    let limite = 10
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }

    @IBAction func ocultarTeclado()
    {
        txfAlias.resignFirstResponder()
    }
    
    @IBAction func validarAlias()
    {
        if txfAlias.text!.count > limite
        {
            txfAlias.text = String(txfAlias.text!.prefix(limite))
        }
    }
    
    @IBAction func entrarChat()
    {
        if txfAlias.text!.count > 1
        {
            var alias = txfAlias.text!
            let faltantes = limite - alias.count
            for _ in 1...faltantes
            {
                alias += " "
            }
            
            let chatVC = ChatViewController()
            chatVC.alias = alias
            chatVC.modalTransitionStyle = .coverVertical
            chatVC.modalPresentationStyle = .fullScreen
            present(chatVC, animated: true)
        }
        else
        {
            let alerta = UIAlertController(title: "ERROR", message: "Debes escoger un alias con al menos dos caracteres", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Aceptar", style: .default)
            alerta.addAction(ok)
            present(alerta, animated: true)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        entrarChat()
        return true
    }
}
