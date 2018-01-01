//
//  addStockViewController.swift
//  Apenas Testando
//
//  Created by Rafael C F Leite on 20/10/2017.
//  Copyright © 2017 Rafael C F Leite. All rights reserved.
//

import UIKit
import CoreData


struct ativos {
    var Papel: String
    var Nome: String
    var Razão: String
}

class addStockViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet weak var codigoLabel: UILabel!
    @IBOutlet weak var nomeLabel: UILabel!
    @IBOutlet weak var qtyTextField: UITextField!
    @IBOutlet weak var precoTextField: UITextField!
    @IBOutlet weak var operacaoAcao: UISegmentedControl!
    @IBOutlet weak var dataOperacao: UIDatePicker!
    @IBOutlet weak var ativosTableView: UITableView!
    @IBOutlet weak var selecionaAtivoView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
//    var delegate : AddStock?
    var searchActive : Bool = false
    var filteredData = [ativos]()
    var ativosArrayFinal = [ativos]()
    
    var codigoDoAtivo: String = ""
    var nomeDoAtivo: String = ""
    
    override func viewWillAppear(_ animated: Bool) {
        
        if codigoDoAtivo != "" {
            selecionaAtivoView.isHidden = true
            codigoLabel.text = codigoDoAtivo
            nomeLabel.text = nomeDoAtivo
        } else {
        carregaAtivos()
        }
        
        selecionaAtivoView.layer.cornerRadius = 10
        
        selecionaAtivoView.layer.shadowColor = UIColor.black.cgColor
        selecionaAtivoView.layer.shadowOpacity = 1
        selecionaAtivoView.layer.shadowRadius = 10
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ativosTableView.delegate = self
        ativosTableView.dataSource = self
        
    }
    
    func carregaAtivos () {
        let path = Bundle.main.path(forResource: "ativos B3", ofType: "plist")
        let ativosArray = NSArray(contentsOfFile: path!) as! [[String:String]]
        
        ativosArrayFinal = ativosArray.map{ativos.init(Papel: $0["Papel"] as! String, Nome: $0["Nome Comercial"] as! String, Razão: $0["Razão Social"] as! String)}
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            return filteredData.count
        } else {
            return ativosArrayFinal.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = ativosTableView.dequeueReusableCell(withIdentifier: "celulaAtivos", for: indexPath)
        
        if(searchActive){
            let item = filteredData[indexPath.row]
            cell.textLabel?.text = item.Papel
            cell.detailTextLabel?.text = item.Nome
        } else {
            let item = ativosArrayFinal[indexPath.row]
            cell.textLabel?.text = item.Papel
            cell.detailTextLabel?.text = item.Nome
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(searchActive){
            let item = filteredData[indexPath.row]
            codigoLabel.text = item.Papel
            nomeLabel.text = item.Nome
        } else {
            let item = ativosArrayFinal[indexPath.row]
            codigoLabel.text = item.Papel
            nomeLabel.text = item.Nome
        }
        selecionaAtivoView.isHidden = true
    }

    @IBAction func addStockButton(_ sender: Any) {
        
        if codigoLabel.text == "" || nomeLabel.text == "" || qtyTextField.text == "" || precoTextField.text == "" {
            
            let alerta = UIAlertController(title: "Parametros Faltantes", message: "Por favor preencha todos os parâmetros da operação", preferredStyle: .alert)
            let estiloAlerta = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alerta.addAction(estiloAlerta)
            present(alerta, animated: true, completion: nil)
            
        } else {
        
            let selecaoOperacao = operacaoAcao.selectedSegmentIndex == 0 ? "C" : "V"
         
            let quantidade: Int = Int(qtyTextField.text!)!
            var preco: Float = 0
            
            let formatter = NumberFormatter()
            formatter.decimalSeparator = ","
            
           
            if let campoTexto = precoTextField.text {
            
                if let p = formatter.number(from: campoTexto) {
                    preco = p.floatValue
                } else {
                    print("Preco not parseable")
                }
            }
            
            let custoOperacao = calculaCustos(qty: quantidade, preco: preco)

//  Trazendo o salvamento da operacao pra este codigo
//            delegate?.addStockToWallet(codigo: codigoLabel.text!, nome: nomeLabel.text!, qty: quantidade, preco: preco, oper: selecaoOperacao, data: dataOperacao.date, custo: custoOperacao)
            

            // Mark:- Salvamento com persistencia
            //
            // Primeiro instacia appDelegate para acessar os metodos da persistencia
            // Depois cria o "contexto", ataves do metodo do appDelegate
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            // Agora cria a requisição de inserir os objetos na entidade "Operações do modelo
            //
            
            let operacoes = NSEntityDescription.insertNewObject(forEntityName: "Operacoes", into: context)
            
            // Insere os valores para cada chave
            //
            operacoes.setValue(codigoLabel.text, forKey: "codigo")
            operacoes.setValue(quantidade, forKey: "quantidade")
            operacoes.setValue(preco, forKey: "preco")
            operacoes.setValue(selecaoOperacao, forKey: "operacao")
            operacoes.setValue(dataOperacao.date, forKey: "data")
            operacoes.setValue(nomeLabel.text, forKey: "nome")
            operacoes.setValue(custoOperacao, forKey: "custo")
            
            // Salva o contexto
            do {
                try context.save()
                print("Sucesso ao salvar os itens no Model.")
            } catch  {
                print("Falha ao salvar dados.")
            }
            
            performSegue(withIdentifier: "unwindToViewController", sender: self)
        }
    }
    
    //MARK: - Metodos para a barra de busca funcionar
    
        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            searchActive = true;
        }
        
        func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
            searchActive = false;
            ativosTableView.reloadData()
        }
    
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchActive = false;
            searchBar.text = ""
            ativosTableView.reloadData()
        }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text == "" {
            searchActive = false
        } else {
            if let text = searchBar.text {
                filteredData = ativosArrayFinal.filter {$0.Papel.lowercased().contains(text.lowercased()) || $0.Nome.lowercased().contains(text.lowercased())}
                searchActive = true
            } else {
                filteredData = []
                searchActive = false
            }
        }
        ativosTableView.reloadData()
    }
    
    func calculaCustos (qty: Int, preco: Float) -> Float {
        
        let custoCorretagem : Float = 18.9
        let custoISS : Float = 1.82
        let custoIR : Float = 0
        let custoOutras : Float = 0.73
        let custoLiquidacao : Float = Float(qty) * preco * 0.0002734
        let custoEmolumento : Float = Float(qty) * preco * 0.00004910714286
        
        let custoOperacao = custoCorretagem + custoISS + custoIR + custoOutras + custoLiquidacao + custoEmolumento
        
        return custoOperacao
        
    }
}

