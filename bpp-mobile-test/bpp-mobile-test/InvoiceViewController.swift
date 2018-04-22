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
    
    var invoiceList: Array<[String: String]> = Array.init()
    var currentInvoice: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        previousButton.isHidden = true
        nextButton.isHidden = true
        
        self.showInvoice(number: currentInvoice);
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
    
    func showInvoice(number: Int)
    {
        DispatchQueue.main.async {
            self.currentInvoice = number
            
            self.table.reloadData()
            
            self.previousButton.isHidden = (self.currentInvoice == 1)
            self.nextButton.isHidden = (self.currentInvoice == self.invoiceList.count)
            
            self.title = String.init(format: "Invoice %d", self.currentInvoice)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailsTableCell") as! InvoiceTableCell
        
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
