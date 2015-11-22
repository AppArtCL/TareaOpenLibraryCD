//
//  ViewController.swift
//  TareaOpenLibraryCD
//
//  Created by Cristian Diaz on 20-11-15.
//  Copyright © 2015 AppArt. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var codigoError = 0
    var texto = ""
    
    @IBOutlet weak var codigoISBN: UITextField!
    @IBOutlet weak var detalleCodigoISBN: UITextView!
    @IBOutlet weak var indicadorActividad: UIActivityIndicatorView!
    
    @IBAction func limpiarCampos(sender: AnyObject) {
        codigoISBN.text = ""
        detalleCodigoISBN.text = ""
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        self.codigoError = 0
        if codigoISBN.text == "" {
            let alerta = UIAlertController(title: "Error en la búsqueda", message: "El código no puede ser vacío.", preferredStyle: UIAlertControllerStyle.Alert)
            alerta.addAction(UIAlertAction(title: "OK", style: .Default, handler: {(alertAction) -> Void in
                self.codigoISBN.text = ""
                self.detalleCodigoISBN.text = ""
            }))
            self.presentViewController(alerta, animated: true, completion: nil)
        } else {
            self.indicadorActividad.startAnimating()
            obtenerTextoISBN2(codigoISBN.text!)
        }
        return true
    }
    
    func obtenerTextoISBN2(codigo:String) {
        self.detalleCodigoISBN.text = "Buscando..."
        let consulta = NSMutableURLRequest(URL: NSURL(string: "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:" + codigo)!)
        let sesion = NSURLSession.sharedSession()
        consulta.HTTPMethod = "GET"
        let task = sesion.dataTaskWithRequest(consulta, completionHandler: {data, respuesta, error -> Void in
            if let datosRespuesta = respuesta as? NSHTTPURLResponse {
                if datosRespuesta.statusCode == 200 {
                    if data != nil {
                        self.texto = String(data: data!, encoding: NSUTF8StringEncoding)!
                        if self.texto == "{}" {
                            self.texto = ""
                            self.codigoError = 2
                        }
                    } else {
                        print(error?.localizedDescription)
                        self.codigoError = 2
                    }
                } else {
                    //self.codigoError = Int(datosRespuesta.statusCode)
                    self.codigoError = 1
                }
            } else {
                self.codigoError = 1
            }
            self.refrescaPantalla()
        })
        task.resume()
    }

    // Espera al termino de la cola y ejecuta los siguientes
    func refrescaPantalla() {
        dispatch_async(dispatch_get_main_queue(), {
            self.detalleCodigoISBN.text = self.texto
            self.indicadorActividad.stopAnimating()
            if self.codigoError == 1 {
                let alerta = UIAlertController(title: "Error en la búsqueda", message: "Existe problema con la conexión a Internet.", preferredStyle: UIAlertControllerStyle.Alert)
                alerta.addAction(UIAlertAction(title: "OK", style: .Default, handler: {(alertAction) -> Void in
                    self.codigoISBN.text = ""
                    self.detalleCodigoISBN.text = ""
                }))

                self.presentViewController(alerta, animated: true, completion: nil)
            } else if self.codigoError == 2 {
                let alerta = UIAlertController(title: "Error en la búsqueda", message:
                    "No existe libro con codigo \(self.codigoISBN.text!)", preferredStyle: .Alert)
                //alerta.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                alerta.addAction(UIAlertAction(title: "OK", style: .Default, handler: {(alertAction) -> Void in
                    self.codigoISBN.text = ""
                    self.detalleCodigoISBN.text = ""
                }))
                self.presentViewController(alerta, animated: true, completion: nil)
            }
            return
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicadorActividad.stopAnimating()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}