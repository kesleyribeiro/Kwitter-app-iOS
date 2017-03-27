//
//  ConvidadoVC.swift
//  Kwitter
//
//  Created by Kesley Ribeiro on 24/Mar/17.
//  Copyright © 2017 AppaoCubo. All rights reserved.
//

import UIKit

class ConvidadoVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // Variável para guardar as informações do usuário convidado passado via segue 'mostrarConvidado'
    var usuarioConvidado = NSDictionary()    
    
    // Objetos da view
    @IBOutlet weak var imagemPerfil: UIImageView!
    @IBOutlet weak var nomeUsuarioLabel: UILabel!
    @IBOutlet weak var nomeCompletoLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    // Objetos da view relacionados aos Posts
    @IBOutlet weak var convidadoTableView: UITableView!
    var kweets = [AnyObject]()
    var imagens = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         // Obter informações do usuário a partir da var. global
         let nomeUsuario = usuarioConvidado["nomeUsuario"] as? String
         let nomeCompleto = usuarioConvidado["nomeCompleto"] as? String
         let email = usuarioConvidado["email"] as? String
         let ava = usuarioConvidado["ava"] as? String
         
         nomeUsuarioLabel.text = nomeUsuario
         nomeCompletoLabel.text = nomeCompleto
         emailLabel.text = email
         
         // Obter imagem de perfil do usuário
         if ava != "" {
         
             // url path para a imagem
             let urlImagem = URL(string: ava!)!
             
             // Obter a fila principal para executar este bloco
             DispatchQueue.main.async(execute: {
             
             // Obtém o dado a partir da urlImage
             let dadoImagem = try? Data(contentsOf: urlImagem)
             
             // Se os dados não são nill, atribuir ao imagemPerfil.image
             if dadoImagem != nil {
                
                     // Obter a fila principal para executar este bloco
                     DispatchQueue.main.async(execute: {
                     self.imagemPerfil.image = UIImage(data: dadoImagem!)
                    })
                 }
             })
         }
        
        // Arredondar bordas
        imagemPerfil.layer.cornerRadius = imagemPerfil.bounds.width / 20
        imagemPerfil.clipsToBounds = true
        
        // Definir o nome de usuário para ser o título da view
        self.navigationItem.title = nomeUsuario?.uppercased()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Chamar a função de carregar os Posts
        carregarPosts()
    }
    
    // TABLE VIEW
    // Números de Cell na TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return kweets.count
    }
    
    // Configuração da Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostCell
        
        // Atribuir para as constantes os dados kweets e as imagens
        let kweet = kweets[indexPath.row]
        let imagem = imagens[indexPath.row]
        let nomeUsuario = kweet["nomeUsuario"] as? String
        let texto = kweet["texto"] as? String
        let data = kweet["data"] as! String
        
        // Convertendo String data para data
        let formatarData = DateFormatter()
        formatarData.dateFormat = "yyyy-MM-dd-HH:mm:ss"
        let novaData = formatarData.date(from: data)!
        
        // Declarar os ajustes
        let aPartir = novaData
        let agora = Date()
        let componentes : NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfMonth]
        let diferenca = (Calendar.current as NSCalendar).components(componentes, from: aPartir, to: agora, options: [])
        
        // Calcular a data do Post
        if diferenca.second! <= 0 {
            cell.dataPostLabel.text = "Agora"
        }
        if diferenca.second! > 0 && diferenca.minute! == 0 {
            cell.dataPostLabel.text = "\(diferenca.second)s." // 10s.
        }
        if diferenca.minute! > 0 && diferenca.hour! == 0 {
            cell.dataPostLabel.text = "\(diferenca.minute)m."
        }
        if diferenca.hour! > 0 && diferenca.day! == 0 {
            cell.dataPostLabel.text = "\(diferenca.hour)h."
        }
        if diferenca.day! > 0 && diferenca.weekOfMonth! == 0 {
            cell.dataPostLabel.text = "\(diferenca.day)d."
        }
        if diferenca.weekOfMonth! > 0 {
            cell.dataPostLabel.text = "\(diferenca.weekOfMonth)w."
        }
        
        // Atribui aos objetos da view as informações do Post do usuário
        cell.nomeUsuarioLabel.text = nomeUsuario
        cell.textoPostLabel.text = texto
        cell.imagemPost.image = imagem
        
        // Obter a fila principal para executar este bloco
        DispatchQueue.main.async {
            
            // Se não tiver imagem na Cell
            if imagem.size.width == 0 && imagem.size.height == 0 {
                
                // Mover o textoPostLabel para a esquerda se o Post não tiver com foto
                cell.textoPostLabel.frame.origin.x = self.view.frame.size.width / 16 // = 20
                cell.textoPostLabel.frame.size.width = self.view.frame.size.width - self.view.frame.size.width / 8 // = 40
                cell.textoPostLabel.sizeToFit()
            }
        }
        return cell
    }
    
    // Função para buscar no BD todos os Posts do usuário e mostrar no app
    func carregarPosts() {
        
        // Obter o id do usuário convidado
        let id = usuarioConvidado["id"]!
        
        // URL para o arquivo PHP
        let url = URL(string: "http://localhost/Kwitter/posts.php")!
        
        // Requisição para este arquivo
        var requisicao = URLRequest(url: url)
        
        // Método para passar os dados para este arquivo via POST
        requisicao.httpMethod = "POST"
        
        // Adicionar na requisição os campos que serão enviados
        let body = "id=\(id)&texto=&uuid="
        
        // Suporte para todos os idiomas
        requisicao.httpBody = body.data(using: .utf8)
        
        // Processar o envio da requisição
        URLSession.shared.dataTask(with: requisicao) { (data, response, error) in
            
            // Obter a fila principal para executar este bloco
            DispatchQueue.main.async(execute: {
                
                // Se não tiver erro
                if error == nil {
                    do {
                        
                        // Obter o resultado JSON
                        let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                        
                        // Limpar
                        self.kweets.removeAll(keepingCapacity: false)
                        self.imagens.removeAll(keepingCapacity: false)
                        self.convidadoTableView.reloadData()
                        
                        // Enviar o objeto JSON para guardar em uma constante
                        guard let parseJSON = json else {
                            print("\nOcorreu um erro ao tentar o parse JSON: \(error)")
                            return
                        }
                        
                        // Declarar uma constante para guardar os posts de parseJSON
                        guard let posts = parseJSON["posts"] as? [AnyObject] else {
                            print("\nOcorreu um erro ao tentar o parse JSON: \(error)")
                            return
                        }
                        
                        // Atribuir para a variável kweets todas as informações dos Posts
                        self.kweets = posts
                        
                        // Obter as imagens a partir do path url
                        for i in 0 ..< self.kweets.count {
                            
                            // Criar um path para obter os dados via $arrayRetorno que foi atribuido ao parseJSON > para posts > kweets
                            let path = self.kweets[i]["path"] as? String
                            
                            // Se encontrar o path
                            if !path!.isEmpty {
                                
                                // Converter a url para string path
                                let url = URL(string: path!)!
                                
                                // Obter o dado via url e atribuir para dadoImagem
                                let dadoImagem = try? Data(contentsOf: url)
                                
                                // Obter a imagem via dadoImagem
                                let imagem = UIImage(data: dadoImagem!)!
                                
                                // Adicionar a imagem encontrada para var imagens
                                self.imagens.append(imagem)
                                
                            }
                            // Se não encontrar o path
                            else {
                                
                                // Criar um do tipo UIImage
                                let image = UIImage()
                                
                                // Adicionar a imagem encontrada para var imagens
                                self.imagens.append(image)
                            }
                        }
                        
                        // Recarregar as informações da tableView
                        self.convidadoTableView.reloadData()
                        
                    } catch {
                        // Obter a fila principal para executar este bloco
                        DispatchQueue.main.async(execute: {
                            let mensagem = "\(error)"
                            appDelegate.infoView(mensagem: mensagem, corAlterada: corAlteradaVermelho)
                        })
                        return
                    }
                    
                } else {
                    // Obter a fila principal para executar este bloco
                    DispatchQueue.main.async(execute: {
                        let mensagem = error!.localizedDescription
                        appDelegate.infoView(mensagem: mensagem, corAlterada: corAlteradaVermelho)
                    })
                    return
                }
            })
        } .resume()
    }
}
