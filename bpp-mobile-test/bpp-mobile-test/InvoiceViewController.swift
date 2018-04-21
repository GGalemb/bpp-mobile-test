//
//  InvoiceViewController.swift
//  bpp-mobile-test
//
//  Created by Gustavo Galembeck on 4/21/18.
//  Copyright © 2018 Gustavo Galembeck. All rights reserved.
//

import UIKit

class InvoiceViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    var invoiceList: Array<[String: String]> = Array.init()
    var currentInvoice: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = ""
        
        previousButton.isHidden = true
        nextButton.isHidden = true

        let url: String = "http://test-mobile.dev-bpp.com.br/invoice"
        var urlRequest = URLRequest(url: URL(string: url)!)
        
        urlRequest.httpMethod = "GET"
        urlRequest.timeoutInterval = 60
        
        let urlSession = URLSession.shared
        
        let request = urlSession.dataTask(with: urlRequest) { (data, response, error) in
            
            var responseJson: Any
            
            if (error != nil) {
                self.showError(message: "Erro no recebimento dos invoices")
                return
            }
            
            do {
                responseJson = try JSONSerialization.jsonObject(with: data!, options: [])
            } catch {
                self.showError(message: "Erro ao processar os invoices")
                return
            }
            
            let response = responseJson as! Array<[String: Any]>
            
            //print("Response: " + response.description)
            
            self.invoiceList.removeAll()
            
            for r in response
            {
                var oneInvoice: [String: String] = Dictionary.init()
                
                oneInvoice["transactionId"] = String.init(format: "%@", r["transactionId"] as! CVarArg)
                oneInvoice["transactionFormattedDate"] = String.init(format: "%@", r["transactionFormattedDate"] as! CVarArg)
                oneInvoice["transactionAmount"] = String.init(format: "%@ %@", r["transactionAmount"] as! CVarArg, r["transactionCurrency"] as! CVarArg)
                oneInvoice["billingAmount"] = String.init(format: "%@ %@", r["billingAmount"] as! CVarArg, r["billingCurrency"] as! CVarArg)
                oneInvoice["transactionStatus"] = String.init(format: "%@", r["transactionStatus"] as! CVarArg)
                oneInvoice["transactionName"] = String.init(format: "%@", r["transactionName"] as! CVarArg)
                oneInvoice["merchantName"] = String.init(format: "%@", r["merchantName"] as! CVarArg)
                oneInvoice["merchantCode"] = String.init(format: "%@ (%@)", r["mccCode"] as! CVarArg, r["mccDescription"] as! CVarArg)
                
                self.invoiceList.append(oneInvoice)
            }
            
            if (self.invoiceList.count > 0) {
                self.showInvoice(number: 1);
            }
            else {
                self.showError(message: "Nenhum invoice recebido")
            }
            
            if (false) //(response["status"] == "error")
            {
                //self.showError(message: String.init(format: "Erro %@: %@", response["code"]!, response["message"]!))
            }
            else
            {
                //self.goToMainMenu()
            }
        }
        
        request.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func previousInvoice() {
        showInvoice(number: currentInvoice - 1)
    }
    
    @IBAction func nextInvoice() {
        showInvoice(number: currentInvoice + 1)
    }
    
    func showError(message: String) {
        DispatchQueue.main.async {
            let alert: UIAlertController = UIAlertController.init(title: "Erro", message: message, preferredStyle: UIAlertControllerStyle.alert)
            
            alert.show(self, sender: self)
        }
    }
    
    func showInvoice(number: Int)
    {
        DispatchQueue.main.async {
            self.currentInvoice = number
            
            self.titleLabel.text = String.init(format: "Invoice %d", self.currentInvoice)
            
            self.table.reloadData()
            
            self.previousButton.isHidden = (self.currentInvoice == 1)
            self.nextButton.isHidden = (self.currentInvoice == self.invoiceList.count)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var num: Int = 0
        
        if (currentInvoice > 0) {
            num = invoiceList[currentInvoice - 1].count
        }
        
        return num
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell") as! InvoiceTableCell
        
        let index: Int = currentInvoice - 1
        
        let invoice: Dictionary = invoiceList[index]
        
        let key: String = keyForPosition(position: indexPath.row)
        
        let cellTitle: String = nameForKey(key: key)
        let cellContents: String = invoice[key]!
        
        cell.titleLabel.text = cellTitle
        cell.contentsLabel.text = cellContents
        
        return cell
    }
    
    // Chaves ordenadas na sequência em que devem aparecer na tabela.
    func keyForPosition(position: Int) -> String {
        var key: String = ""
        
        switch (position)
        {
            case 0:
                key = "transactionId"
            break
            
            case 1:
                key = "transactionFormattedDate"
            break
            
            case 2:
                key = "transactionAmount"
            break
            
            case 3:
                key = "billingAmount"
            break
            
            case 4:
                key = "transactionStatus"
            break
            
            case 5:
                key = "transactionName"
            break
            
            case 6:
                key = "merchantName"
            break
            
            case 7:
                key = "merchantCode"
            break
            
            default:
                print("Posição inválida: ", position);
            break
        }
        
        return key;
    }
    
    // Possíveis traduções do aplicativo serão tratadas aqui
    func nameForKey(key: String) -> String {
        var name: String = ""
        
        switch (key)
        {
            case "transactionId":
                name = "ID da transação"
            break
            
            case "transactionFormattedDate":
                name = "Data da transação"
            break
            
            case "transactionAmount":
                name = "Valor da transação"
            break
            
            case "billingAmount":
                name = "Valor da cobrança"
            break
            
            case "transactionStatus":
                name = "Status da transação"
            break
            
            case "transactionName":
                name = "Nome técnico da transação"
            break
            
            case "merchantName":
                name = "Nome do estabelecimento"
            break
            
            case "merchantCode":
                name = "Tipo de estabelecimento"
            break
            
            default:
                print("Key inválida: ", key);
            break
        }
        
        return name;
    }
}
