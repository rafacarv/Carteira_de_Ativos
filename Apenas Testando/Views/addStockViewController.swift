//
//  addStockViewController.swift
//  Apenas Testando
//
//  Created by Rafael C F Leite on 20/10/2017.
//  Copyright © 2017 Rafael C F Leite. All rights reserved.
//

import UIKit
import CoreData


protocol AddStock {
    func addStockToWallet (codigo: String, nome: String, qty: Int, preco: Float, oper: String, data: Date, custo: Float)
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
    
    var delegate : AddStock?
    var ativosArray : [[String:String]] = [[:]]
    
    override func viewWillAppear(_ animated: Bool) {
//        codigoTextField.becomeFirstResponder()
         carregaAtivos()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ativosTableView.delegate = self
        ativosTableView.dataSource = self
        
        
        selecionaAtivoView.layer.cornerRadius = 3
        
        selecionaAtivoView.layer.shadowColor = UIColor.black.cgColor
        selecionaAtivoView.layer.shadowOpacity = 1
        selecionaAtivoView.layer.shadowOffset = CGSize.zero
        selecionaAtivoView.layer.shadowRadius = 10
        
    }
    
    func carregaAtivos () {
        let path = Bundle.main.path(forResource: "ativos B3", ofType: "plist")
        ativosArray = NSArray(contentsOfFile: path!) as! [[String:String]]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ativosArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = ativosTableView.dequeueReusableCell(withIdentifier: "celulaAtivos", for: indexPath)
        let item = ativosArray[indexPath.row]
        
        cell.textLabel?.text = item["Papel"]
        cell.detailTextLabel?.text = item["Nome Comercial"]

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = ativosArray[indexPath.row]
        codigoLabel.text = item["Papel"]
        nomeLabel.text = item["Nome Comercial"]
        
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
            
            let p = formatter.number(from: precoTextField.text!)
            
            if let pr = p?.floatValue {
                preco = pr
            } else {
                print("Preco not parseable")
            }
            
            let custoOperacao = calculaCustos(qty: quantidade, preco: preco)
            
            delegate?.addStockToWallet(codigo: codigoLabel.text!, nome: nomeLabel.text!, qty: quantidade, preco: preco, oper: selecaoOperacao, data: dataOperacao.date, custo: custoOperacao)
            
            performSegue(withIdentifier: "unwindToViewController", sender: self)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
       
        
        
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
