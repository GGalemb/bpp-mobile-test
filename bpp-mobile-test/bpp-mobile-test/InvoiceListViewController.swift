//
//  InvoiceListViewController.swift
//  bpp-mobile-test
//
//  Created by Gustavo Galembeck on 4/21/18.
//  Copyright © 2018 Gustavo Galembeck. All rights reserved.
//

import UIKit

class InvoiceListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var invoiceList: Array<[String: String]> = Array.init()
    var selectedInvoice: Int = 0
    
    let dateFormatterSourceDate: DateFormatter = DateFormatter.init()
    let dateFormatterSourceTime: DateFormatter = DateFormatter.init()
    let dateFormatterReadableDate: DateFormatter = DateFormatter.init()
    let dateFormatterReadableTime: DateFormatter = DateFormatter.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        
        dateFormatterSourceDate.dateFormat = "yyyy-MM-dd"
        dateFormatterSourceTime.dateFormat = "HH:mm:ss"
        
        dateFormatterReadableDate.dateFormat = "dd/MM/yyyy"
        dateFormatterReadableTime.dateFormat = "HH:mm"
        
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
            
            self.invoiceList.removeAll()
            
            for r in response
            {
                
                var oneInvoice: [String: String] = Dictionary.init()
                
                oneInvoice["transactionId"] = String.init(format: "%@", r["transactionId"] as! CVarArg)
                oneInvoice["transactionFormattedDate"] = self.readableDateAndTime(sourceDateTime: r["transactionFormattedDate"] as! String)
                oneInvoice["transactionAmount"] = self.readableValue(sourceValue: r["transactionAmount"], sourceUnit: r["transactionCurrency"])
                oneInvoice["billingAmount"] = self.readableValue(sourceValue: r["billingAmount"], sourceUnit: r["billingCurrency"])
                oneInvoice["transactionStatus"] = String.init(format: "%@", r["transactionStatus"] as! CVarArg)
                oneInvoice["transactionName"] = String.init(format: "%@", r["transactionName"] as! CVarArg)
                oneInvoice["merchantName"] = String.init(format: "%@", r["merchantName"] as! CVarArg)
                oneInvoice["merchantCode"] = String.init(format: "%@ (%@)", r["mccCode"] as! CVarArg, r["mccDescription"] as! CVarArg)
                
                self.invoiceList.append(oneInvoice)
            }
            
            if (self.invoiceList.count == 0) {
                self.showError(message: "Nenhum invoice recebido")
            }
            else {
                self.showInvoices()
            }
        }
        
        request.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "detailsSegue")
        {
            let vc: InvoiceViewController = segue.destination as! InvoiceViewController
            
            vc.title = String.init(format: "Invoice %d", self.selectedInvoice)
            vc.invoiceList = invoiceList
            vc.currentInvoice = selectedInvoice
        }
    }
    
    func showError(message: String) {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true

            let alert: UIAlertController = UIAlertController.init(title: "Erro", message: message, preferredStyle: UIAlertControllerStyle.alert)
            
            alert.show(self, sender: self)
        }
    }
    
    func showInvoices()
    {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            
            self.table.reloadData()
        }
    }
    
    func showInvoice(number: Int)
    {
        DispatchQueue.main.async {
            self.selectedInvoice = number
            
            self.performSegue(withIdentifier: "detailsSegue", sender: self)
        }
    }
    
    func readableDateAndTime(sourceDateTime: String) -> String {
        let separator: CharacterSet = CharacterSet.init(charactersIn: "T")
        
        let dateStringParts: Array = sourceDateTime.components(separatedBy: separator)
        
        let dateString: String = dateStringParts[0]
        let timeString: String = dateStringParts[1]
        
        let date: Date? = dateFormatterSourceDate.date(from: dateString)
        let time: Date? = dateFormatterSourceTime.date(from: timeString)
        
        var finalDateString: String
        
        if ((date != nil) && (time != nil)) {
            finalDateString = String.init(format: "%@ %@", dateFormatterReadableDate.string(for: date)!, dateFormatterReadableTime.string(for: time)!)
        } else {
            finalDateString = String.init(format: "%@ %@", dateString, timeString)
        }
        
        return finalDateString
    }
    
    func readableValue(sourceValue: Any!, sourceUnit: Any!) -> String {
        let sourceValueString: String = String.init(format: "%@", sourceValue as! CVarArg)
        let sourceUnitString: String = String.init(format: "%@", sourceUnit as! CVarArg)
        
        let separator: CharacterSet = CharacterSet.init(charactersIn: ".")
        
        let valueComponents: Array = sourceValueString.components(separatedBy: separator)
        
        let valueA: Int64 = Int64(valueComponents[0])!
        let valueStringA: String = String.init(format: "%lld", valueA)
        
        let valueB: Int64 = (valueComponents.count > 1) ? Int64(valueComponents[1])! : 0
        var valueStringB: String = String.init(format: "%lld", valueB)
        
        if (valueStringB.count == 1) {
            valueStringB = "0" + valueStringB
        } else if (valueStringB.count > 2) {
            valueStringB = String.init(valueStringB.dropLast(valueStringB.count - 2))
        }
        
        let unit: String = (sourceUnitString == "BRL") ? "R$" : ""
        let complement: String = (sourceUnitString == "BRL") ? "" : sourceUnitString
        
        return String.init(format: "%@%@,%@ %@", unit, valueStringA, valueStringB, complement)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return invoiceList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listTableCell") as! InvoiceListTableCell
        
        let invoice: Dictionary = invoiceList[indexPath.row]
        
        let cellMerchant: String = invoice["merchantName"]!
        let cellStatus: String = invoice["transactionStatus"]!
        let cellDate: String = invoice["transactionFormattedDate"]!
        let cellValue: String = invoice["billingAmount"]!

        cell.merchantLabel.text = cellMerchant
        cell.valueLabel.text = String.init(format: "%@ (%@)", cellValue, cellStatus)
        cell.dateLabel.text = cellDate
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showInvoice(number: (indexPath.row + 1))
    }
}
