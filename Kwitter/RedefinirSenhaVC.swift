//
//  RedefinirSenhaVC.swift
//  Kwitter
//
//  Created by Kesley Ribeiro on 14/Mar/17.
//  Copyright © 2017 AppaoCubo. All rights reserved.
//

import UIKit

class RedefinirSenhaVC: UIViewController {

    // Objeto da view
    @IBOutlet weak var emailTxt: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // Botão Redefinir
    @IBAction func redefinirSenhaButton(_ sender: Any) {

        // Atribuir para a constante o valor informado pelo usuário
        let email = emailTxt.text!.lowercased()
        
        // Se email não for preenchido
        if email.isEmpty {

            // Placeholder fica com texto em vermelho
            emailTxt.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName: UIColor.red])
        }
        // Se email estiver preenchido - enviar requisição para MYSQL / PHP
        else {
            
            // Remover o teclado
            self.view.endEditing(false)

            // URL para o arquivo PHP
            let url = URL(string: "http://localhost/Kwitter/redefinirSenha.php")!

            // Requisição para este arquivo
            var requisicao = URLRequest(url: url)

            // Método para passar os dados para este arquivo via POST
            requisicao.httpMethod = "POST"

            // Campo a ser adicionado na url
            let body = "email=\(email)"

            // Suporte para todos os idiomas
            requisicao.httpBody = body.data(using: .utf8)

            // Processar o envio da requisição
            URLSession.shared.dataTask(with: requisicao) { (data, response, error) in

                // se não tiver erro
                if error == nil {
                    
                    // Obter a fila principal para executer este bloco
                    DispatchQueue.main.async(execute: {
                        do {
                            // Obtér o resultado JSON
                            let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary

                            // Enviar o objeto JSON para guardar em uma constante
                            guard let parseJSON = json else {
                                print("\nErro ao tentar fazer o parse do JSON\n")
                                return
                            }
                            
                            // Obter email a partir do dicionário parseJSON
                            let email = parseJSON["email"]
                            
                            // Sucesso para redefinir a senha
                            if email != nil {
                                
                                // Obter a fila principal para executer este bloco
                                DispatchQueue.main.async(execute: {
                                    let mensagem = parseJSON["mensagem"] as! String
                                    appDelegate.infoView(mensagem: mensagem, corAlterada: corAlteradaVerde)
                                })

                            }
                            // Ocorreu um erro
                            else {
                                // Obter a fila principal para executer este bloco
                                DispatchQueue.main.async(execute: {
                                    let mensagem = parseJSON["mensagem"] as! String
                                    appDelegate.infoView(mensagem: mensagem, corAlterada: corAlteradaVermelho)
                                })
                                return
                            }
                        }
                        catch {
                            // Obter a fila principal para executer este bloco
                            DispatchQueue.main.async(execute: {
                                let mensagem = "\(error)"
                                appDelegate.infoView(mensagem: mensagem, corAlterada: corAlteradaVermelho)
                            })
                            return
                        }
                    })
                }
                // Erro na requisição
                else {
                    
                    // Obter a fila principal para executer este bloco
                    DispatchQueue.main.async(execute: {
                        let mensagem = error!.localizedDescription
                        appDelegate.infoView(mensagem: mensagem, corAlterada: corAlteradaVermelho)
                    })
                    return
                }
            }.resume()
        }
    }
    
    // Status bar em branco
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    // Quando usuário tocar na tela
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Esconder o teclado
        self.view.endEditing(false)
    }
}
