import ActivityKit
import AppIntents
import SwiftUI
import WidgetKit

@main
struct WgerRestWidgets: WidgetBundle {
  var body: some Widget { WgerRestWidget() }
}

/// What the activity shows at the moment. Once a countdown is over iOS marks
/// the activity stale (staleDate = end of the rest), without the app running,
/// and the widget switches to the `after*` texts, e.g. "Rest over" and the set.
@available(iOS 16.2, *)
private struct Shown {
  let title: String
  let body: String
  let subtitle: String?
  let countdown: ClosedRange<Date>?
  let countUpFrom: Date
  let resting: Bool
  let canLog: Bool
  let canSkip: Bool
  let canExtend: Bool

  init(_ state: WgerRestAttributes.ContentState, stale: Bool) {
    let over = stale && state.timerTo != nil
    if over {
      title = state.afterTitle ?? state.title
      body = state.afterBody ?? ""
      subtitle = state.afterSubtitle
      countdown = nil
      countUpFrom = state.workoutStart
      resting = false
      canLog = state.afterCanLog
      canSkip = false
      canExtend = state.afterCanExtend
    } else {
      title = state.title
      body = state.body
      subtitle = state.subtitle
      if let end = state.timerTo, end > state.timerFrom {
        countdown = state.timerFrom...end
      } else {
        countdown = nil
      }
      countUpFrom = state.timerFrom
      resting = state.resting
      canLog = state.canLog
      canSkip = state.canSkip
      canExtend = state.canExtend
    }
  }
}

@available(iOS 16.2, *)
struct WgerRestWidget: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: WgerRestAttributes.self) { context in
      let shown = Shown(context.state, stale: context.isStale)
      VStack(alignment: .leading, spacing: 10) {
        HStack(alignment: .center, spacing: 14) {
          ring(shown).frame(width: 44, height: 44)
          VStack(alignment: .leading, spacing: 2) {
            if let subtitle = shown.subtitle {
              Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Text(shown.title).font(.headline).lineLimit(1)
            if !shown.body.isEmpty {
              Text(shown.body).font(.subheadline).lineLimit(2)
            }
          }
          Spacer(minLength: 8)
          timer(shown).font(.title2.monospacedDigit()).multilineTextAlignment(.trailing)
            .frame(maxWidth: 96, alignment: .trailing)
        }
        buttons(context.state, shown)
      }
      .padding()
      .activityBackgroundTint(Color.black)
      .activitySystemActionForegroundColor(.white)
      .foregroundStyle(.white)
    } dynamicIsland: { context in
      let shown = Shown(context.state, stale: context.isStale)
      return DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          ring(shown).frame(width: 40, height: 40)
        }
        DynamicIslandExpandedRegion(.trailing) {
          timer(shown).font(.title2.monospacedDigit()).multilineTextAlignment(.trailing)
            .frame(maxWidth: 96, alignment: .trailing)
        }
        DynamicIslandExpandedRegion(.center) {
          VStack(spacing: 2) {
            if let subtitle = shown.subtitle {
              Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Text(shown.title).font(.headline).lineLimit(1)
          }
        }
        DynamicIslandExpandedRegion(.bottom) {
          VStack(spacing: 8) {
            if !shown.body.isEmpty {
              Text(shown.body).font(.subheadline).lineLimit(2)
            }
            buttons(context.state, shown)
          }
        }
      } compactLeading: {
        ring(shown).frame(width: 22, height: 22)
      } compactTrailing: {
        timer(shown).monospacedDigit().multilineTextAlignment(.trailing).frame(maxWidth: 56)
      } minimal: {
        ring(shown)
      }
      .keylineTint(.blue)
    }
  }

  @ViewBuilder
  private func ring(_ shown: Shown) -> some View {
    if let countdown = shown.countdown {
      ProgressView(timerInterval: countdown, countsDown: true) {
        EmptyView()
      } currentValueLabel: {
        Image(systemName: "pause.fill").font(.caption2)
      }
      .progressViewStyle(.circular).tint(.blue)
    } else {
      Image(systemName: shown.resting ? "pause.circle.fill" : "dumbbell.fill")
        .foregroundStyle(.blue)
    }
  }

  /// Rest countdown, else the time since the rest or workout started
  @ViewBuilder
  private func timer(_ shown: Shown) -> some View {
    if let countdown = shown.countdown {
      Text(timerInterval: countdown, countsDown: true)
    } else {
      Text(shown.countUpFrom, style: .timer)
    }
  }

  @ViewBuilder
  private func buttons(_ state: WgerRestAttributes.ContentState, _ shown: Shown) -> some View {
    if #available(iOS 17.0, *) {
      if shown.canLog || shown.canSkip || shown.canExtend {
        HStack(spacing: 8) {
          if shown.canLog {
            Button(intent: WorkoutIslandIntent(action: WorkoutIslandAction.logSet,
                                               payload: state.payload)) {
              Label(state.logLabel, systemImage: "checkmark").frame(maxWidth: .infinity)
            }
          }
          if shown.canSkip {
            Button(intent: WorkoutIslandIntent(action: WorkoutIslandAction.skipRest,
                                               payload: state.payload)) {
              Label(state.skipLabel, systemImage: "forward.end").frame(maxWidth: .infinity)
            }
          }
          if shown.canExtend {
            Button(intent: WorkoutIslandIntent(action: WorkoutIslandAction.extendRest,
                                               payload: state.payload)) {
              Text(state.extendLabel).frame(maxWidth: .infinity)
            }
          }
        }
        .font(.caption.weight(.semibold))
        .buttonStyle(.bordered)
        .tint(.blue)
        .lineLimit(1)
      }
    }
  }
}
