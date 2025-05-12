//
//  ChatViewController.swift
//  Chat9B
//
//  Created by Igmar Salazar on 12/06/24.
//

import UIKit

class ChatViewController: UIViewController, URLSessionWebSocketDelegate, UITextViewDelegate
{
    var alias: String!
    var webSocket: URLSessionWebSocketTask!
    var cargando =  UIActivityIndicatorView()
    var scrMensajes = UIScrollView()
    var txvMensaje = UITextView()
    var btnEnviar = UIButton()
    var hscr = 0.0, ctxv = 0.0, alturaMsj = 0.0

    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = .white
        let noti = NotificationCenter.default
        noti.addObserver(self, selector: #selector(tecladoAparece), name: UIResponder.keyboardWillShowNotification, object: nil)
        noti.addObserver(self, selector: #selector(tecladoDesaparece), name: UIResponder.keyboardWillHideNotification, object: nil)
        noti.addObserver(self, selector: #selector(appMinimizada), name: UIApplication.didEnterBackgroundNotification, object: nil)
        noti.addObserver(self, selector: #selector(appMaximizada), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    //Se usará para establecer la conexión con el WebSocket
    override func viewWillAppear(_ animated: Bool)
    {
        let sesion = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
        let url = URL(string: "wss://free.blr2.piesocket.com/v3/1?api_key=zAXETLds0B7tupz4aK7XZQqTYRY2SDs4WlGwcHOn")
        webSocket = sesion.webSocketTask(with: url!)
        webSocket.resume()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        cargando = UIActivityIndicatorView(frame: CGRect(x: view.frame.width/2.0 - 25, y: view.frame.height/2.0 - 25, width: 50, height: 50))
        cargando.color = .black
        cargando.style = .large
        cargando.startAnimating()
        view.addSubview(cargando)
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?)
    {
        print("Conectado al Servidor")
        cargando.stopAnimating()
        recibirMensaje()
        dibujarPantalla()
    }
    
    func textViewDidChange(_ textView: UITextView)
    {
        if textView.contentSize.height != ctxv
        {
            let dif = textView.contentSize.height - ctxv
            if dif > 0.0
            {
                if ctxv < 100.0
                {
                    ctxv = textView.contentSize.height
                    txvMensaje.frame.origin.y -= dif
                    txvMensaje.frame.size.height = ctxv
                    btnEnviar.frame.origin.y = txvMensaje.frame.origin.y
                    scrMensajes.frame.size.height -= dif
                }
            }
            else
            {
                ctxv = textView.contentSize.height
                txvMensaje.frame.origin.y -= dif
                txvMensaje.frame.size.height = ctxv
                btnEnviar.frame.origin.y = txvMensaje.frame.origin.y
                scrMensajes.frame.size.height -= dif
            }
        }
    }
    
    func recibirMensaje()
    {
        DispatchQueue.main.async {
            self.webSocket.receive { resultado in
                switch resultado
                {
                case .success(let exito):
                    switch exito
                    {
                    case .string(let mensaje):
                        self.dibujarGloboMensaje(mensaje, false)
                    case .data(let datos):
                        print(datos)
                        //let json = try? JSONSerialization.jsonObject(with: datos) as! [[String:Any]]
                    default:
                        print("ERROR DESCONOCIDO")
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
                self.recibirMensaje()
            }
        }
    }
    
    func enviarMensajeSocket()
    {
        if txvMensaje.text.count > 0
        {
            let msj = alias! + txvMensaje.text!
            DispatchQueue.main.async {
                self.webSocket.send(.string(msj)) { error in
                    if let err = error
                    {
                        print(err.localizedDescription)
                    }
                    else
                    {
                        self.dibujarGloboMensaje(msj, true)
                    }
                }
            }
        }
    }
    
    func dibujarPantalla()
    {
        hscr = view.frame.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom - 60
        scrMensajes.frame = CGRect(x: 10, y: view.safeAreaInsets.top + 5.0, width: view.frame.width - 20.0, height: hscr)
        scrMensajes.showsVerticalScrollIndicator = false
        scrMensajes.backgroundColor = .clear
        view.addSubview(scrMensajes)
        
        txvMensaje.frame = CGRect(x: 10, y: scrMensajes.frame.origin.y + hscr + 5.0, width: scrMensajes.frame.width - 45.0, height: 40)
        txvMensaje.font = .systemFont(ofSize: 20, weight: .medium)
        txvMensaje.layer.borderWidth = 1
        txvMensaje.layer.cornerRadius = 15
        txvMensaje.delegate = self
        ctxv = txvMensaje.contentSize.height
        view.addSubview(txvMensaje)
        
        btnEnviar.frame = CGRect(x: view.frame.width - 50.0, y: txvMensaje.frame.origin.y, width: 40, height: 50)
        btnEnviar.setImage(UIImage(systemName: "arrowshape.right.fill"), for: .normal)
        btnEnviar.tintColor = .red
        btnEnviar.addTarget(self, action: #selector(enviarMensaje), for: .touchUpInside)
        
        view.addSubview(btnEnviar)
    }
    
    @objc func tecladoAparece(_ notificacion:Notification)
    {
        if let frameTeclado = notificacion.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        {
            let altura = frameTeclado.cgRectValue.height - view.safeAreaInsets.bottom
            hscr -= altura
            scrMensajes.frame.size.height = hscr
            txvMensaje.frame.origin.y = scrMensajes.frame.origin.y + hscr + 5.0
            btnEnviar.frame.origin.y = txvMensaje.frame.origin.y
            
            if scrMensajes.contentSize.height > hscr
            {
                scrMensajes.setContentOffset(CGPoint(x: 0, y: scrMensajes.contentSize.height), animated: true)
            }
        }
    }
    
    @objc func tecladoDesaparece(_ notificacion:Notification)
    {
        hscr = view.frame.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom - 60
        scrMensajes.frame.size.height = hscr
        txvMensaje.frame.origin.y = scrMensajes.frame.origin.y + hscr + 5.0
        ctxv = 40.0
        txvMensaje.frame.size.height = ctxv
        btnEnviar.frame.origin.y = txvMensaje.frame.origin.y
    }
    
    @objc func enviarMensaje(_ sender: UIButton)
    {
        view.endEditing(true)
        enviarMensajeSocket()
        txvMensaje.text = ""
    }
    
    func dibujarGloboMensaje(_ mensaje:String, _ propio:Bool)
    {
        let ali = String(mensaje.prefix(10))
        let msj = mensaje.suffix(mensaje.count-10)
        
        let txvGlobo = UITextView(frame:CGRect(x: 0, y: alturaMsj, width: scrMensajes.frame.width*0.6, height: 40))
        txvGlobo.font = .systemFont(ofSize: 18, weight: .medium)
        txvGlobo.text = "\(ali)\n\n\(msj)"
        txvGlobo.layer.borderWidth = 1
        txvGlobo.layer.cornerRadius = 15
        if propio
        {
            txvGlobo.frame.origin.x = scrMensajes.frame.width * 0.4
            txvGlobo.backgroundColor = .cyan
        }
        else
        {
            txvGlobo.backgroundColor = .orange
        }
        let cs = txvGlobo.contentSize.height
        txvGlobo.frame.size.height = cs
        txvGlobo.isEditable = false
        scrMensajes.addSubview(txvGlobo)
        alturaMsj += cs + 5
        scrMensajes.contentSize = CGSize(width: 0, height: alturaMsj)
        
        if scrMensajes.contentSize.height > hscr
        {
            scrMensajes.setContentOffset(CGPoint(x: 0, y: scrMensajes.contentSize.height), animated: true)
        }
    }
    
    @objc func appMinimizada()
    {
        webSocket.cancel(with: .normalClosure, reason: nil)
    }
    
    @objc func appMaximizada()
    {
        
    }
}
