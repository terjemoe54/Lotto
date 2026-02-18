// PrintController.swift
// Lotto
//
// SwiftUI wrapper for UIPrintInteractionController to print a SwiftUI View

import SwiftUI
import UIKit

/// SwiftUI wrapper that renders content to one or more pages.
struct PrintController<Content: View>: UIViewControllerRepresentable {
    let content: Content
    let title: String?
    let date: Date?
    let completion: (() -> Void)?
    
    /// Creates a host controller used to present the print sheet.
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        controller.view.backgroundColor = .clear
        DispatchQueue.main.async {
            printView(from: controller)
        }
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    /// Renders the content and sends it to the printer as page images.
    private func printView(from controller: UIViewController) {
        let pageSize = CGSize(width: 612, height: 792) // Letter-size points
        let margin: CGFloat = 24
        let headerHeight: CGFloat = 36
        let footerHeight: CGFloat = 28
        let contentWidth = pageSize.width - (margin * 2)
        let contentHeightPerPage = pageSize.height - (margin * 2) - headerHeight - footerHeight
        let headerText = formattedHeader()
        let rootView = content
            .frame(width: contentWidth)
            .padding()
            .background(Color.white)
        let hosting = UIHostingController(rootView: rootView)
        hosting.view.backgroundColor = UIColor.white

        let targetSize = CGSize(width: contentWidth, height: .greatestFiniteMagnitude)
        let contentSize: CGSize
        if #available(iOS 16.0, *) {
            contentSize = hosting.sizeThatFits(in: targetSize)
        } else {
            contentSize = hosting.view.systemLayoutSizeFitting(
                targetSize,
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            )
        }

        let totalHeight = max(contentHeightPerPage, contentSize.height)
        hosting.view.bounds = CGRect(x: 0, y: 0, width: contentWidth, height: totalHeight)
        hosting.view.layoutIfNeeded()

        let pageCount = Int(ceil(totalHeight / contentHeightPerPage))
        let renderer = UIGraphicsImageRenderer(size: pageSize)
        var images: [UIImage] = []
        images.reserveCapacity(pageCount)

        for pageIndex in 0..<pageCount {
            let image = renderer.image { context in
                let offsetY = CGFloat(pageIndex) * contentHeightPerPage
                context.cgContext.translateBy(x: margin, y: margin + headerHeight - offsetY)
                hosting.view.drawHierarchy(in: hosting.view.bounds, afterScreenUpdates: true)
                context.cgContext.translateBy(x: -margin, y: -margin - headerHeight + offsetY)
                drawHeaderFooter(
                    in: context.cgContext,
                    pageSize: pageSize,
                    headerText: headerText,
                    pageIndex: pageIndex,
                    pageCount: pageCount,
                    margin: margin,
                    headerHeight: headerHeight,
                    footerHeight: footerHeight
                )
            }
            images.append(image)
        }

        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .general
        printInfo.jobName = "Lotto Resultater"

        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo
        printController.printingItems = images

        printController.present(from: controller.view.frame, in: controller.view, animated: true) { _, _, _ in
            completion?()
        }
    }

    /// Builds the header text with title and optional date.
    private func formattedHeader() -> String {
        guard let title else {
            return ""
        }
        guard let date else {
            return title
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return "\(title) – \(formatter.string(from: date))"
    }

    /// Draws header and footer directly on the page.
    private func drawHeaderFooter(
        in context: CGContext,
        pageSize: CGSize,
        headerText: String,
        pageIndex: Int,
        pageCount: Int,
        margin: CGFloat,
        headerHeight: CGFloat,
        footerHeight: CGFloat
    ) {
        if !headerText.isEmpty {
            let headerRect = CGRect(
                x: margin,
                y: margin,
                width: pageSize.width - (margin * 2),
                height: headerHeight
            )
            let headerAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 14),
                .foregroundColor: UIColor.black
            ]
            NSString(string: headerText).draw(in: headerRect, withAttributes: headerAttrs)
        }

        let footerText = "Page \(pageIndex + 1) of \(pageCount)"
        let footerRect = CGRect(
            x: margin,
            y: pageSize.height - margin - footerHeight,
            width: pageSize.width - (margin * 2),
            height: footerHeight
        )
        let footerAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.darkGray
        ]
        NSString(string: footerText).draw(in: footerRect, withAttributes: footerAttrs)
    }
}
