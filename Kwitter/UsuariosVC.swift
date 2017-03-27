//
//  UsuariosVC.swift
//  Kwitter
//
//  Created by Kesley Ribeiro on 23/Mar/17.
//  Copyright © 2017 AppaoCubo. All rights reserved.
//

import UIKit

class UsuariosVC: UITableViewController, UISearchBarDelegate {

    // Objeto da view
    @IBOutlet weak var usuariosSearchBar: UISearchBar!

    // Array de objetos com todas as informações do usuário
    var usuarios = [AnyObject]()
    var imagens = [UIImage]()

    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Customização na searchBar
        usuariosSearchBar.barTintColor = .white // Cor da searchBar
        usuariosSearchBar.tintColor = corAzul // Elementos da searchBar
        usuariosSearchBar.showsCancelButton = false
        
        // Chamar função para pesquisar usuário
        pesquisarPalavra("")
    }
    
    // Quando informado um texo na searchBar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // Chamar função para pesquisar usuário
        pesquisarPalavra(searchBar.text!)
    }
    
    // Se iniciar a edição de texto na searchBar...
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        // Mostrar o botão cancelar (x)
        usuariosSearchBar.showsCancelButton = true
    }
    
    // Quando clicar no botão cancelar (x) da searchBar
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        // Resetar UI
        usuariosSearchBar.endEditing(false) // Remover teclado
        usuariosSearchBar.showsCancelButton = false // Remover botão cancelar (x)
        usuariosSearchBar.text = "" // Apagar texto, se houver algum
        
        // Limpar
        usuarios.removeAll(keepingCapacity: false)
        imagens.removeAll(keepingCapacity: false)
        tableView.reloadData()
        
        // Chamar função para pesquisar usuário
        pesquisarPalavra("")
    }

    // MARK: - Table view data source

    // Número de Cells na tableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usuarios.count
    }
    
    // Configurar a Cell na tableView
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UsuariosCell

        // Obter um por um usuario relacionado às informações da varivável usuarios
        let usuario = usuarios[indexPath.row]
        let imagem = imagens[indexPath.row]
        
        // Atribuir para as constantes o nome de usuário e o nome completo do atual usuário
        let nomeUsuario = usuario["nomeUsuario"] as? String
        let nomeCompleto = usuario["nomeCompleto"] as? String
        
        // Atribuir para objetos da Cell as informações do usuários
        cell.nomeUsuarioLabel.text = nomeUsuario
        cell.nomeCompletoLabel.text = nomeCompleto
        cell.imagemPerfil.image = imagem

        return cell
    }

    // Função para pesquisar dados do usuário
    func pesquisarPalavra(_ palavra: String) {
     
        // Atribuir para a constante a palavra informada na searchBar
        let palavra = usuariosSearchBar.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        // Atribuir para a constante o nome de usuário do atual usuário
        let nomeUsuario = usuario!["nomeUsuario"] as! String
        
        // Acessar o arquivo
        let url = URL(string: "http://localhost/Kwitter/usuarios.php")!
        
        // Requisição para este arquivo
        var requisicao = URLRequest(url: url)
        
        // Método para passar os dados para este arquivo via POST
        requisicao.httpMethod = "POST"
        
        // Campos a serem adicionados na url
        let body = "palavra=\(palavra)&nomeUsuario=\(nomeUsuario)"
        
        // Suporte para todos os idiomas
        requisicao.httpBody = body.data(using: .utf8)
        
        // Processar o envio da requisição
        URLSession.shared.dataTask(with: requisicao) { data, response, error in
            
            // Obter a fila principal para executer este bloco
            DispatchQueue.main.async(execute: {
                
                // Se não tiver erro
                if error == nil {
                    do {
                        
                        // Obter o resultado JSON
                        let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                        
                        // Limpar
                        self.usuarios.removeAll(keepingCapacity: false)
                        self.imagens.removeAll(keepingCapacity: false)
                        self.tableView.reloadData()

                        // Enviar o objeto JSON para guardar em uma constante
                        guard let parseJSON = json else {
                            print("\nOcorreu um erro ao tentar o parse JSON: \(error)")
                            return
                        }
                        
                        // Declarar uma constante para guardar os posts de parseJSON
                        guard let parseUSUARIOS = parseJSON["usuarios"] else {
                            print(parseJSON["mensagem"] ?? [NSDictionary]())
                            return
                        }
                        
                        // Adicionar $arrayRetorno["usuarios"] para variáel self.usuarios
                        self.usuarios = parseUSUARIOS as! [AnyObject]
                        
                        // Obter a imagem a partir do path url
                        for i in 0 ..< self.usuarios.count {
                            
                            // Obter o path do arquivo imagem do usuario
                            let imagem = self.usuarios[i]["ava"] as? String
                            
                            // Se encontrar o path -> carregar imagem via path
                            if !imagem!.isEmpty {
                                
                                // Converter a url para string path
                                let url = URL(string: imagem!)!
                                
                                // Obter o dado via url e atribuir para dadoImagem
                                let dadoImagem = try? Data(contentsOf: url)
                                
                                // Obter a imagem via dadoImagem
                                let imagem = UIImage(data: dadoImagem!)!
                                
                                // Adicionar a imagem encontrada para var imagens
                                self.imagens.append(imagem)
                                
                            } // Se não encontrar o path
                            else {
                                // Criar um do tipo UIImage
                                let imagem = UIImage(named: "imagem.jpg")
                                
                                // Adicionar a imagem encontrada para var imagens
                                self.imagens.append(imagem!)
                            }
                        }

                        // Recarregar as informações da tableView
                        self.tableView.reloadData()
                        
                    } catch {
                        // Obter a fila principal para executar este bloco
                        DispatchQueue.main.async(execute: {
                            let mensagem = "\(error)"
                            appDelegate.infoView(mensagem: mensagem, corAlterada: corAlteradaVermelho)
                        })
                        return
                    }
                }
                // Ocorreu um erro
                else {
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
    
    // Continuação para segue que foi feita na main.storyboard para um outro view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Verificar se existir a cell e se for selecionada uma cell
        if let cell = sender as? UITableViewCell {
            
            // Definir um index para depois enviar exatamente as informações relacionadas ao usuário convidado
            let index = tableView.indexPath(for: cell)!.row
            
            // Se segue igual a "mostrarConvidado" ...
            if segue.identifier == "mostrarConvidado" {
                
                // Chamar o view controller "ConvidadoVC" para acessar a variável "convidado"
                let convidado = segue.destination as! ConvidadoVC
                
                // Atribuir para variável "convidado" as informações do usuário convidado
                convidado.usuarioConvidado = usuarios[index] as! NSDictionary

                // Botão 'voltar' sem o título
                let botaoVoltar = UIBarButtonItem()
                botaoVoltar.title = ""
                navigationItem.backBarButtonItem = botaoVoltar
            }
        }
    }
    
}
