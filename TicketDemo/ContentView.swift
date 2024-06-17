//
//  ContentView.swift
//  TicketDemo
//
//  Created by Brian Masse on 6/17/24.
//

import SwiftUI

//MARK: Line
@available(iOS 15.0, *)
struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: .init(x: rect.minX, y: rect.midY))
        path.addLine(to: .init(x: rect.maxX, y: rect.midY))
        
        return path
    }
}

//MARK: Ticket Shape
@available(iOS 15.0, *)
struct TicketShape: Shape {
    static func Corner(in rect: CGRect) -> Path {
        let inset = TicketView.ticketCornerInset
        var path = Path()
        
        path.move(to: .init(x: rect.maxX - inset, y: rect.maxY))
        
        path.addLine(to: .init(x: rect.maxX - inset, y: rect.minY + inset))
        path.addLine(to: .init(x: rect.minX, y: rect.minY + inset))
        path.addLine(to: .init(x: rect.minX, y: rect.maxY))
        
        return path
    }
    
    static func InvertedRoundedCorner( in rect: CGRect ) -> Path {
        var path = Path()
        
        path.move(to: .init(x: rect.maxX, y: rect.minY))
        path.addArc(center: .init(x: rect.maxX, y: rect.minY),
                    radius: rect.height,
                    startAngle: .init(degrees: 180),
                    endAngle: .init(degrees: 90), clockwise: true)
        
        return path
    }

    var corner: ( CGRect ) -> Path
    
    init(  corner: @escaping (CGRect) -> Path ) {
        self.corner = corner
    }
    
    private func makeTicketStub(in rect: CGRect) -> Path {
        var path = Path()
        
        
        path.addArc(center: .init(x: rect.maxX, y: rect.minY + rect.height * TicketView.ticketStubHeight),
                    radius: TicketView.ticketCornerRadius,
                    startAngle: .degrees(-90), endAngle: .degrees(90),
                    clockwise: true)
        
        path.move(to: .init(x: rect.minX, y: rect.minY + rect.height * TicketView.ticketStubHeight))
        path.addArc(center: .init(x: rect.minX, y: rect.minY + rect.height * TicketView.ticketStubHeight),
                    radius: TicketView.ticketCornerRadius,
                    startAngle: .degrees(90), endAngle: .degrees(-90),
                    clockwise: true)
        
        return path
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        
        let inset = TicketView.ticketCornerInset
        let radius = TicketView.ticketCornerRadius
        
        let xOffsets: [Double] = [ -1, 0, 0, -1 ]
        let yOffsets: [Double] = [ 0, 0, -1, -1 ]
        
        for i in 0..<4 {
            let baseX = xOffsets[i] == 0 ? rect.minX : rect.maxX
            let baseY = yOffsets[i] == 0 ? rect.minY : rect.maxY
            
            let cornerRect = CGRect(x: baseX + (xOffsets[i] * ( radius + inset )),
                                    y: baseY + (yOffsets[i] * ( radius + inset )),
                                    width: radius + inset,
                                    height: radius + inset)
            
            let rotation: Double = -90 * Double(i)
            let corner = self.corner( cornerRect )
                .rotation(.degrees(rotation)).path(in: cornerRect)
            
            path.addPath(corner)
        }
        
//        mark body
        let body = CGRect(x: rect.minX, y: rect.minY,
                          width: rect.width, height: rect.height)
        
        path.addRect(body)
        
//        mark ticket stub
        let stubs = makeTicketStub(in: rect)
        path.addPath(stubs)
        
        return path
    }
}





//MARK: Ticket
public struct Ticket {
    let id: String = UUID().uuidString
    
    let title: String
    let description: String
    
    let name: String
    let phoneNumber: String
    
    let image: String = "painting"
    
    let date: Date
    let price: String
    
    public init(title: String, description: String, name: String, phoneNumber: String, date: Date, price: String) {
        self.title = title
        self.description = description
        self.name = name
        self.phoneNumber = phoneNumber
        self.date = date
        self.price = price
    }
}

//MARK: TicketView
@available(iOS 15.0, *)
public struct TicketView: View {
    
//    the position of where the ticket should be 'seperable' into the ticket stub
//    normalized from the top
    static let ticketStubHeight: CGFloat = 0.75
    static let ticketImageHeight: CGFloat = 200
    
    static let ticketCornerInset: CGFloat = 0
    static let ticketCornerRadius: CGFloat = 20
    
    static let lightColor: Color = .init(red: 252/255, green: 251/255, blue: 245/255)
    
    let ticket: Ticket
    
    private func formatDate() -> String {
        "\(ticket.date.formatted(date: .abbreviated, time: .omitted))\n \(ticket.date.formatted(date: .omitted, time: .shortened))"
    }
    
//    MARK: ViewBuilders
    @ViewBuilder
    private func makeCutLine() -> some View {
        VStack(spacing: 5) {
            Spacer()
            Rectangle()
                .stroke(style: .init(lineWidth: 1, lineCap: .round, dash: [3, 5]))
                .frame(height: 1)
                .padding(.horizontal)
            
            Line()
                .stroke(style: .init(lineWidth: 3, lineCap: .round, dash: [10, 10] ))
                .frame(height: 1)
                .opacity(0.3)
                .padding(.horizontal)
            
            Spacer()
        }
    }
    
    
    @ViewBuilder
    private func makeTopContent(fullContent: Bool = true) -> some View {
        VStack {
            HStack(spacing: 10) {
                Group {
                    Text( ticket.id )
                        .font(.footnote)
                        .frame(width: 7)
                    
                    Rectangle()
                        .frame(width: 3)
                }.padding(.bottom, 30)
                
                VStack(alignment: .leading) {
                    Text( ticket.title )
                        .textCase(.uppercase)
                        .font(.title)
//                        .bold()
                    
                    Text( ticket.description )
                        .padding(.bottom, 15)
                    
                    Text( formatDate() )
//                        .bold()
                        .font(.caption)
                    Spacer()
                }
            }
            Spacer()
            
            if fullContent {
                HStack {
                    VStack(alignment: .leading) {
                        Text( ticket.name )
//                            .bold()
                        Text( ticket.phoneNumber )
                    }
                    
                    Spacer()
                    
                    Text( "$\(ticket.price)" )
                        .font(.headline)
//                        .bold()
                }
            }
        }
        .padding( .top, TicketView.ticketCornerRadius + 10 )
        .padding( .horizontal, TicketView.ticketCornerRadius )
    }
    
    @ViewBuilder
    private func makeTicketImage() -> some View {
        ZStack {
            Image( ticket.image )
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: TicketView.ticketImageHeight)
        }
    }
    
    public init(ticket: Ticket) {
        self.ticket = ticket
    }
    
//    MARK: Body
    public var body: some View {
        GeometryReader { geo in
            ZStack {
                TicketView.lightColor
                
                Image(ticket.image)
                    .resizable()
                    .blur(radius: 60)
                    .opacity(0.2)
                    .clipped()
                
                VStack(spacing: 0) {
                    makeTopContent()
                        .padding(.bottom)
                        .frame(height: geo.size.height * TicketView.ticketStubHeight
                               - TicketView.ticketImageHeight
                               - TicketView.ticketCornerRadius )
                    
                    makeTicketImage()
                    
                    makeCutLine()
                        .frame(height: TicketView.ticketCornerRadius * 2)
                    
                    makeTopContent(fullContent: false)
                }
                .foregroundStyle(.black)
                
                TicketShape(corner: TicketShape.InvertedRoundedCorner)
                    .stroke(lineWidth: 1)
                    .opacity(0.5)
            }
        }
        .aspectRatio(17/40, contentMode: .fit)
        .clipShape(TicketShape( corner: TicketShape.InvertedRoundedCorner ))
        
        .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 10)
        
        .padding()
    }
}


//MARK: ContentView
@available(iOS 15.0, *)
private struct ContentView: View {
    
    let ticket = Ticket(title: "Full Meseum Access",
                        description: "Expore all the exhibitions of the BMFA as long as you want",
                        name: "Brian Masse",
                        phoneNumber: "(781) 315 3811",
                        date: .now,
                        price: "9.99")
    
    var body: some View {
        TicketView(ticket: ticket)
    }
}

//#Preview {
//    ContentView()
//}
