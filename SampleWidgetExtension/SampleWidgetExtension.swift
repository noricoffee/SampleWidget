//
//  SampleWidgetExtension.swift
//  SampleWidgetExtension
//
//  Created by Noriyuki Yoshida on 2024/11/29.
//

import AppIntents
import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), image: nil, string: "placeholder")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), image: nil, string: "getSnapshot")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
//        var entries: [SimpleEntry] = []
//
//        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
//        let currentDate = Date()
//        for hourOffset in 0 ..< 5 {
//            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
//            let entry = SimpleEntry(date: entryDate, image: UIImage(systemName: "bell.fill")!)
//            entries.append(entry)
//        }
//
//        let timeline = Timeline(entries: entries, policy: .atEnd)
//        completion(timeline)
        
//        Task {
//            print("aaaaaaaaaaaaaaaaa timeline")
//            guard let image = try? await DoggyFetcher.fetchRandomDoggy() else {
//                return
//            }
//            
//            let entry = SimpleEntry(date: Date(), image: image)
//            
//            let timeline = Timeline(entries: [entry], policy: .atEnd)
//            completion(timeline)
//        }
        
        Task {
            guard let url = UserDefaults.standard.url(forKey: "dog_image_url") else {
                return
            }
            
            let (imageData, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: imageData) else {
                return
            }
            let userdefaults = UserDefaults(suiteName: "group.net.noricoffee.SampleWidget.widget")
            let string = userdefaults?.string(forKey: "sampleAppInputText") ?? "nil"
            let entry = SimpleEntry(date: Date(), image: image, string: string)
            
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let image: UIImage?
    let string: String
}

struct SampleWidgetExtensionEntryView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    
    var entry: Provider.Entry

    var body: some View {
        
        switch family {
        case .systemMedium, .systemLarge:
            HStack {
                Image(uiImage: entry.image ?? UIImage())
                    .resizable()
                    .scaledToFill()
                VStack {
                    Text(formattedDate(date: entry.date))
                        .foregroundStyle(.black)
                        .font(.headline)
                        .fontWeight(.semibold)
                    Text(entry.date, style: .time)
                        .foregroundStyle(.black)
                        .font(.title)
                        .fontWeight(.bold)

                    Button(intent: SampleIntent(), label: {
                        Text("出勤")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 20)
                    })
                    .tint(.white)
                    .background(.mint)
                    .clipShape(.capsule)
                    
                    Text(entry.string)
                        .foregroundStyle(.black)
                        .font(.footnote)
                    
                }
            }
            .frame(maxWidth: .infinity)
        default:
            VStack {
                Text(formattedDate(date: entry.date))
                    .foregroundStyle(.white)
                    .font(.headline)
                    .fontWeight(.semibold)
                Text(entry.date, style: .time)
                    .foregroundStyle(.white)
                    .font(.title)
                    .fontWeight(.bold)

                Button(intent: SampleIntent(), label: {
                    Text("出勤")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 20)
                })
                .tint(.white)
                .background(.mint)
                .clipShape(.capsule)
                
                Text(entry.string)
                    .foregroundStyle(.white)
                    .font(.footnote)
                
            }
            .background(
                Image(uiImage: entry.image ?? UIImage())
                    .resizable()
                    .scaledToFill()
            )
            .frame(maxWidth: .infinity)
        }
    }
    
    func formattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月d(E)"
        return formatter.string(from: date)
    }
}

struct SampleWidgetExtension: Widget {
    let kind: String = "SampleWidgetExtension"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                SampleWidgetExtensionEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                SampleWidgetExtensionEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies(supportedFamilies)
    }

    // accessoryInlineなどはロック画面用
    private var supportedFamilies: [WidgetFamily] {
        if #available(iOSApplicationExtension 16.0, *) {
            return [
                .systemSmall,
                .systemMedium,
                .systemLarge,
                .systemExtraLarge,
                .accessoryInline,
                .accessoryCircular,
                .accessoryRectangular,
            ]
        } else {
            return [
                .systemSmall,
                .systemMedium,
                .systemLarge,
            ]
        }
    }
}

#Preview(as: .systemSmall) {
    SampleWidgetExtension()
} timeline: {
    SimpleEntry(date: .now, image: UIImage(), string: "")
    SimpleEntry(date: .now, image: UIImage(), string: "")
}
