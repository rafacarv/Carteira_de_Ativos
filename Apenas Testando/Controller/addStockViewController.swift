//
//  addStockViewController.swift
//  Apenas Testando
//
//  Created by Rafael C F Leite on 20/10/2017.
//  Copyright © 2017 Rafael C F Leite. All rights reserved.
//

import UIKit
import CoreData
import JBDatePicker

struct ativos {
    var Papel: String
    var Nome: String
    var Razão: String
}

class addStockViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, JBDatePickerViewDelegate {
    
    @IBOutlet weak var codigoLabel: UILabel!
    @IBOutlet weak var nomeLabel: UILabel!
    @IBOutlet weak var dataLabel: UITextField!
    @IBOutlet weak var qtyTextField: UITextField!
    @IBOutlet weak var precoTextField: UITextField!
    @IBOutlet weak var operacaoAcao: UISegmentedControl!
    @IBOutlet weak var ativosTableView: UITableView!
    @IBOutlet weak var selecionaAtivoView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var liquidacaoTF: UITextField!
    @IBOutlet weak var emolumentosTF: UITextField!
    @IBOutlet weak var corretagemTF: UITextField!
    @IBOutlet weak var issTF: UITextField!
    @IBOutlet weak var liquidoTF: UILabel!
    @IBOutlet weak var outrasTF: UITextField!
    @IBOutlet weak var liquidoFinalLabel: UILabel!
    
    var searchActive : Bool = false
    var filteredData = [ativos]()
    var ativosArrayFinal = [ativos]()
    
    var codigoDoAtivo: String = ""
    var nomeDoAtivo: String = ""
    var dataOperacao: Date = NSDate() as Date
    
    var datePicker: JBDatePickerView!
    
    override func viewWillAppear(_ animated: Bool) {
        
        if codigoDoAtivo != "" {
            selecionaAtivoView.isHidden = true
            codigoLabel.text = codigoDoAtivo
            nomeLabel.text = nomeDoAtivo
        } else {
            selecionaAtivoView.layer.cornerRadius = 2
            selecionaAtivoView.layer.shadowColor = UIColor.black.cgColor
            selecionaAtivoView.layer.shadowOpacity = 1
            selecionaAtivoView.layer.shadowRadius = 3
            selecionaAtivoView.layer.masksToBounds = true
            selecionaAtivoView.isHidden = false
            carregaAtivos()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let formatoData = DateFormatter()
        formatoData.dateFormat = ("dd-mm-yyyy")
        formatoData.locale = Locale(identifier: "pt_BR")
        formatoData.dateStyle = .short
        formatoData.timeStyle = .none
        
        ativosTableView.delegate = self
        ativosTableView.dataSource = self
        
        dataLabel.text = formatoData.string(from: dataOperacao)
    }
    
    func carregaAtivos () {
        let path = Bundle.main.path(forResource: "ativos B3", ofType: "plist")
        let ativosArray = NSArray(contentsOfFile: path!) as! [[String:String]]
        
        ativosArrayFinal = ativosArray.map{ativos.init(Papel: $0["Papel"]!, Nome: $0["Nome Comercial"]!, Razão: $0["Razão Social"]!)}
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
    
    @IBAction func dataTFSelected(_ sender: Any) {
        
        var shouldLocalize: Bool { return true }
        var weekDaysViewHeightRatio: CGFloat { return 0.2 }
        var colorForDayLabelInMonth: UIColor { return UIColor.white }
        var colorForCurrentDay: UIColor { return UIColor.red }
        var colorForWeekDaysViewBackground: UIColor { return UIColor.blue }
        
        let frameForDatePicker = CGRect(x: 0, y: 100, width: view.bounds.width, height: 250)
        datePicker = JBDatePickerView(frame: frameForDatePicker)
        datePicker.backgroundColor = UIColor.flatWhite
        datePicker.layer.cornerRadius = 4
        datePicker.layer.borderWidth = 1
        view.addSubview(datePicker)
        datePicker.delegate = self
    }
    
    func didSelectDay(_ dayView: JBDatePickerDayView) {
        
        let formatoData = DateFormatter()
        formatoData.dateFormat = ("dd-mm-yyyy")
        formatoData.locale = Locale(identifier: "pt_BR")
        formatoData.dateStyle = .short
        formatoData.timeStyle = .none
        
        print("date selected: \(String(describing: dayView.date))")
        datePicker.removeFromSuperview()
        dataOperacao = dayView.date!
        dataLabel.text = formatoData.string(from: dataOperacao)
    }

    @IBAction func addStockButton(_ sender: Any) {
        
        if codigoLabel.text == "" || nomeLabel.text == "" || qtyTextField.text == "" || precoTextField.text == "" {
            
            let alerta = UIAlertController(title: "Parametros Faltantes", message: "Por favor preencha todos os parâmetros da operação", preferredStyle: .alert)
            let estiloAlerta = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alerta.addAction(estiloAlerta)
            present(alerta, animated: true, completion: nil)
            
        } else {
    
            let formatter = NumberFormatter()
            formatter.decimalSeparator = ","
            formatter.numberStyle = .decimal
            formatter.alwaysShowsDecimalSeparator = true
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
            
            let selecaoOperacao = operacaoAcao.selectedSegmentIndex == 0 ? "C" : "V"
            
//            let quantidade: Int = Int(qtyTextField.text!)!
            
            guard let quantidade: Int = Int(qtyTextField.text!) else {
                print ("Problemas lendo o campo Preço")
                return
            }
            
            guard let preco: Float = formatter.number(from: precoTextField.text!)?.floatValue else {
                print ("Problemas lendo o campo Preço")
                return
            }
            
            guard let custoCorretagem: Float = formatter.number(from: corretagemTF.text!)?.floatValue else {
                print ("Problemas lendo o campo Custo Corretagem")
                return
            }

            guard let custoLiquidacao: Float = formatter.number(from: liquidacaoTF.text!)?.floatValue else {
                print ("Problemas lendo o campo Custo Liquidacao")
                return
            }
            guard let custoEmolumento: Float = formatter.number(from: emolumentosTF.text!)?.floatValue else {
                print ("Problemas lendo o campo Custo emolumentos")
                return
            }
            guard let custoISS: Float = formatter.number(from: issTF.text!)?.floatValue else {
                print ("Problemas lendo o campo Custo ISS")
                return
            }
            
            guard let custoOutras: Float = formatter.number(from: outrasTF.text!)?.floatValue else {
                print ("Problemas lendo o campo Custo Outras")
                return
            }

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
            operacoes.setValue(dataOperacao, forKey: "data")
            operacoes.setValue(nomeLabel.text, forKey: "nome")
            operacoes.setValue(custoCorretagem, forKey: "custoCorretagem")
            operacoes.setValue(custoLiquidacao, forKey: "custoLiquidacao")
            operacoes.setValue(custoEmolumento, forKey: "custoEmolumento")
            operacoes.setValue(custoISS, forKey: "custoISS")
            operacoes.setValue(custoOutras, forKey: "custoOutras")
            
            
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
    
    
    //MARK: - Recalcula os custos todas as vezes que houverem mudanças nos campos de quantidade, preço ou tipo da operação
    //
    @IBAction func qtyChanged(_ sender: UITextField) {
        chamaCalculaCustos()
    }
    
    @IBAction func precoChanged(_ sender: UITextField) {
        chamaCalculaCustos()
    }

    @IBAction func operacaoChanged(_ sender: UISegmentedControl) {
        chamaCalculaCustos()
    }
    
    //MARK: - Metodos para a barra de busca funcionar
    //
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
    
    // Funções que calculam os custos das operações e atualizam a tela
    //
    
    func chamaCalculaCustos () {
        let formatter = NumberFormatter()
        formatter.decimalSeparator = ","
        //formatter.locale = Locale.current
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.numberStyle = .decimal
        
        var preco : Float = 0
        
        if qtyTextField.text != ""{
            let checkQty = qtyTextField.text
            if let checkPreco = precoTextField.text {
                if let p = formatter.number(from: checkPreco) {
                    preco = p.floatValue
                    calculaCustos(qty: Int(checkQty!)!, preco: preco)
                } else {
                    print ("Nao deu pra entender o preco")
                }
            }else{
                print("Preco nao foi preenchido ainda")
            }
        } else {
            print ("Quantidade ainda não foi preenchida")
        }
    }
    
    func calculaCustos (qty: Int, preco: Float) {
        
        let formatter = NumberFormatter()
        formatter.decimalSeparator = ","
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        formatter.alwaysShowsDecimalSeparator = true
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        let defaults = UserDefaults.standard
        let check = defaults.string(forKey: "DadosSalvos")

        if check != nil{
            let valorCorretagem = defaults.float(forKey: "Corretagem")
            let valorLiquidacao:Float = defaults.float(forKey: "Liquidacao")
            let valorEmolumentos:Float = defaults.float(forKey: "Emolumentos")
            let valorISS:Float = defaults.float(forKey: "ISS")
            let valorOutras:Float = defaults.float(forKey: "Outras")
            
            let valorLiquido : Float = Float(qty) * preco
            let custoCorretagem : Float = valorCorretagem
            let custoLiquidacao : Float = Float(qty) * preco * (valorLiquidacao/100)
            let custoEmolumento : Float = Float(qty) * preco * (valorEmolumentos/100)
            let custoISS : Float = (valorISS/100) * valorCorretagem
            let custoOutras : Float = valorOutras
            
            if operacaoAcao.selectedSegmentIndex == 0 {
                // compra
                let liquidoFinal = valorLiquido + custoCorretagem + custoEmolumento + custoLiquidacao + custoISS + custoOutras
                liquidoFinalLabel.text = formatter.string(from: liquidoFinal as NSNumber)
            } else {
                // venda
                let liquidoFinal = valorLiquido - custoCorretagem - custoEmolumento - custoLiquidacao - custoISS - custoOutras
                liquidoFinalLabel.text = formatter.string(from: liquidoFinal as NSNumber)
            }
           
            liquidoTF.text = formatter.string(from: valorLiquido as NSNumber)
            liquidacaoTF.text = formatter.string(from: custoLiquidacao as NSNumber)
            emolumentosTF.text = formatter.string(from: custoEmolumento as NSNumber)
            corretagemTF.text = formatter.string(from: custoCorretagem as NSNumber)
            issTF.text = formatter.string(from: custoISS as NSNumber)
            
        } else {
            let valorCorretagem:Float = 1
            let valorLiquidacao:Float = 1
            let valorEmolumentos:Float = 1
            let valorISS:Float = 1
            let valorOutras:Float = 1
            
            let valorLiquido : Float = Float(qty) * preco
            let custoCorretagem : Float = valorCorretagem
            let custoLiquidacao : Float = Float(qty) * preco * valorLiquidacao
            let custoEmolumento : Float = Float(qty) * preco * valorEmolumentos
            let custoISS : Float = valorISS
            let custoOutras : Float = valorOutras
            
            if operacaoAcao.selectedSegmentIndex == 0 {
                // compra
                let liquidoFinal = valorLiquido + custoCorretagem + custoEmolumento + custoLiquidacao + custoISS + custoOutras
                liquidoFinalLabel.text = formatter.string(from: liquidoFinal as NSNumber)
            } else {
                //venda
                let liquidoFinal = valorLiquido - custoCorretagem - custoEmolumento - custoLiquidacao - custoISS - custoOutras
                liquidoFinalLabel.text = formatter.string(from: liquidoFinal as NSNumber)
            }
            
            liquidoTF.text = formatter.string(from: valorLiquido as NSNumber)
            liquidacaoTF.text = formatter.string(from: custoLiquidacao as NSNumber)
            emolumentosTF.text = formatter.string(from: custoEmolumento as NSNumber)
            corretagemTF.text = formatter.string(from: custoCorretagem as NSNumber)
            issTF.text = formatter.string(from: custoISS as NSNumber)

        }
    }
}

