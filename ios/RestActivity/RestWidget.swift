import ActivityKit
import SwiftUI
import WidgetKit

@main
struct WgerRestWidgets: WidgetBundle {
  var body: some Widget { WgerRestWidget() }
}

struct WgerRestWidget: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: WgerRestAttributes.self) { context in
      HStack(spacing: 16) {
        ring(context.state).frame(width: 48, height: 48)
        VStack(alignment: .leading) {
          Text("wger · " + context.state.label).font(.headline)
          countdown(context.state).font(.largeTitle.monospacedDigit())
        }
        Spacer()
      }
      .padding()
      .activityBackgroundTint(Color.black)
      .activitySystemActionForegroundColor(.white)
      .foregroundStyle(.white)
    } dynamicIsland: { context in
      DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          ring(context.state).frame(width: 44, height: 44)
        }
        DynamicIslandExpandedRegion(.trailing) {
          countdown(context.state).font(.title.monospacedDigit())
        }
        DynamicIslandExpandedRegion(.bottom) {
          Text("wger · " + context.state.label).font(.headline)
        }
      } compactLeading: {
        ring(context.state).frame(width: 22, height: 22)
      } compactTrailing: {
        countdown(context.state).monospacedDigit().frame(width: 48)
      } minimal: {
        ring(context.state)
      }
      .keylineTint(.blue)
    }
  }

  private func ring(_ state: WgerRestAttributes.ContentState) -> some View {
    ProgressView(timerInterval: state.start...state.end, countsDown: true) {
      EmptyView()
    } currentValueLabel: {
      Image(systemName: "dumbbell.fill").font(.caption2)
    }
    .progressViewStyle(.circular).tint(.blue)
  }

  private func countdown(_ state: WgerRestAttributes.ContentState) -> some View {
    Text(timerInterval: state.start...state.end, countsDown: true)
  }
}
