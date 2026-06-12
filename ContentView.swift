import SwiftUI
import Foundation
import Combine
import UIKit

struct TreatmentPlan {
    var session1Angle: Int = 92
    var session2Angle: Int = 94
    var session3Angle: Int = 96
    var holdMinutes: Int = 5
    var isLocked: Bool = false
}

struct AvatarProfile {
    var skinColor: Color = Color(red: 0.74, green: 0.52, blue: 0.38)
    var eyeColor: Color = .brown
    var visorColor: Color = .cyan
    var suitBaseColor: Color = .white
    var suitStripeColor: Color = .blue
    var chestPanelColor: Color = .black
    var gloveBootColor: Color = .blue
    var patchColor: Color = .orange

    var rocketBodyColor: Color = .white
    var rocketNoseColor: Color = .red
    var rocketFinColor: Color = .red
    var rocketWindowColor: Color = .cyan
}

func planetName(_ index: Int) -> String {
    if index == 0 { return "Aurora Shores" }
    if index == 1 { return "Oceanus Prime" }
    return "Nebula Ridge"
}

func planetSubtitle(_ index: Int) -> String {
    if index == 0 { return "Crystal Lagoon" }
    if index == 1 { return "Coral City Reef" }
    return "Starlight Canyon"
}

func targetAngle(for session: Int, plan: TreatmentPlan) -> Int {
    if session == 1 { return plan.session1Angle }
    if session == 2 { return plan.session2Angle }
    return plan.session3Angle
}

struct ContentView: View {
    @State private var screen = "welcome"
    @State private var role = ""
    @State private var username = ""
    @State private var password = ""
    @State private var loginError = ""

    @State private var patientSavedUsername = "patient"
    @State private var patientSavedPassword = "0000"
    @State private var parentSavedUsername = "parent"
    @State private var parentSavedPassword = "1111"
    @State private var therapistNotes = "PT Notes:\n- Complete all assigned sessions.\n- Keep the brace aligned with the knee joint.\n- Stop if pain feels sharp or unsafe."
    @State private var parentCheckInNote = ""

    @State private var plan = TreatmentPlan()
    @State private var avatar = AvatarProfile()

    @State private var currentSession = 1
    @State private var currentPlanetIndex = 0
    @State private var missionTimeRemaining = 300
    @State private var timerRunning = false

    var body: some View {
        ZStack {
            SpaceBackground()

            switch screen {
            case "welcome":
                WelcomeScreen(screen: $screen, role: $role)
            case "login":
                LoginScreen(screen: $screen, role: role, username: $username, password: $password, loginError: $loginError, patientSavedUsername: $patientSavedUsername, patientSavedPassword: $patientSavedPassword, parentSavedUsername: $parentSavedUsername, parentSavedPassword: $parentSavedPassword)
            case "signup":
                SignUpScreen(screen: $screen, role: role, patientSavedUsername: $patientSavedUsername, patientSavedPassword: $patientSavedPassword, parentSavedUsername: $parentSavedUsername, parentSavedPassword: $parentSavedPassword)
            case "notes":
                TherapistNotesScreen(screen: $screen, therapistNotes: $therapistNotes)
            case "parentCheckIn":
                ParentCheckInScreen(screen: $screen, plan: plan, currentSession: currentSession, currentPlanetIndex: currentPlanetIndex, missionTimeRemaining: missionTimeRemaining, parentCheckInNote: $parentCheckInNote)
            case "avatarCreator":
                AvatarCreatorScreen(screen: $screen, avatar: $avatar)
            case "rocketCreator":
                RocketCreatorScreen(screen: $screen, avatar: $avatar)
            case "ptPlan":
                PTPlanScreen(screen: $screen, plan: $plan)
            case "patientDashboard":
                PatientDashboard(screen: $screen, plan: plan, avatar: avatar, currentSession: currentSession, currentPlanetIndex: currentPlanetIndex, isPTView: role == "pt")
            case "rocketFueling":
                RocketFuelingScreen(screen: $screen, currentSession: $currentSession, currentPlanetIndex: currentPlanetIndex, plan: plan, avatar: avatar)
            case "earthLaunch":
                EarthLaunchScreen(screen: $screen, avatar: avatar)
            case "spaceTravel":
                SpaceTravelScreen(screen: $screen, avatar: avatar)
            case "planetArrival":
                PlanetArrivalScreen(screen: $screen, avatar: avatar, planetIndex: currentPlanetIndex, currentSession: currentSession, plan: plan)
            case "missionChoice":
                MissionChoiceScreen(screen: $screen, currentPlanetIndex: currentPlanetIndex, plan: plan, missionTimeRemaining: $missionTimeRemaining, timerRunning: $timerRunning)
            case "alienFishing":
                AlienFishingGameScreen(screen: $screen, avatar: avatar, currentSession: $currentSession, currentPlanetIndex: $currentPlanetIndex, missionTimeRemaining: $missionTimeRemaining, timerRunning: $timerRunning)
            case "crystalCollector":
                CrystalCollectorGameScreen(screen: $screen, currentSession: $currentSession, currentPlanetIndex: $currentPlanetIndex, missionTimeRemaining: $missionTimeRemaining, timerRunning: $timerRunning)
            case "treasureHunt":
                DeepSeaTreasureHuntScreen(screen: $screen, currentSession: $currentSession, currentPlanetIndex: $currentPlanetIndex, missionTimeRemaining: $missionTimeRemaining, timerRunning: $timerRunning)
            case "reefBuilder":
                ReefBuilderScreen(screen: $screen, currentSession: $currentSession, currentPlanetIndex: $currentPlanetIndex, missionTimeRemaining: $missionTimeRemaining, timerRunning: $timerRunning)
            case "missionTimerOnly":
                MissionTimerOnlyScreen(screen: $screen, currentSession: $currentSession, currentPlanetIndex: $currentPlanetIndex, missionTimeRemaining: $missionTimeRemaining, timerRunning: $timerRunning)
            case "landingCongrats":
                LandingCongratsScreen(screen: $screen)
            case "secondLandingCongrats":
                SecondLandingCongratsScreen(screen: $screen)
            case "missionComplete":
                MissionCompleteScreen(screen: $screen, currentPlanetIndex: $currentPlanetIndex)
            case "planetTransit":
                PlanetTransitScreen(screen: $screen, currentSession: $currentSession, currentPlanetIndex: $currentPlanetIndex, avatar: avatar)
            default:
                WelcomeScreen(screen: $screen, role: $role)
            }
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            if timerRunning && missionTimeRemaining > 0 {
                missionTimeRemaining -= 1
            }

            if timerRunning && missionTimeRemaining == 0 {
                timerRunning = false
                screen = "missionComplete"
            }
        }
    }
}

// MARK: - Welcome / Login

struct WelcomeScreen: View {
    @Binding var screen: String
    @Binding var role: String

    var body: some View {
        ZStack {
            WelcomeSpaceDecorations()

            VStack(spacing: 18) {
                HStack {
                    Button {
                        screen = "notes"
                    } label: {
                        Text("📝 Notes")
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(.black.opacity(0.42))
                            .cornerRadius(16)
                    }

                    Spacer()
                }
                .padding(.top, 70)

                Spacer()

                Text("KneeHero")
                    .font(.system(size: 52, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .cyan.opacity(0.8), radius: 12)

                Text("Space Command")
                    .font(.title2)
                    .foregroundColor(.cyan)
                    .shadow(radius: 6)

                Text("Rehabilitation missions for knee extension therapy")
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)

                Spacer()

                Button {
                    role = "patient"
                    screen = "login"
                } label: {
                    Text("Patient Login").mainButton(color: .blue)
                }

                Button {
                    role = "parent"
                    screen = "login"
                } label: {
                    Text("Parent Check-In").mainButton(color: .purple)
                }

                Button {
                    role = "pt"
                    screen = "login"
                } label: {
                    Text("PT Login").mainButton(color: .green)
                }

                Spacer()
            }
            .padding(.horizontal, 28)
        }
    }
}

struct LoginScreen: View {
    @Binding var screen: String
    let role: String
    @Binding var username: String
    @Binding var password: String
    @Binding var loginError: String
    @Binding var patientSavedUsername: String
    @Binding var patientSavedPassword: String
    @Binding var parentSavedUsername: String
    @Binding var parentSavedPassword: String

    var roleTitle: String {
        if role == "pt" { return "PT Login" }
        if role == "parent" { return "Parent Login" }
        return "Patient Login"
    }

    var helperText: String {
        if role == "pt" { return "Use: pt / 1234" }
        if role == "parent" { return "Use saved parent account or create one" }
        return "Use saved patient account or create one"
    }

    var body: some View {
        VStack(spacing: 16) {
            Text(roleTitle)
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundColor(.white)

            Text(helperText)
                .foregroundColor(.white.opacity(0.75))
                .multilineTextAlignment(.center)

            TextField("Username", text: $username)
                .textFieldStyleCustom()

            SecureField("Password", text: $password)
                .textFieldStyleCustom()

            if !loginError.isEmpty {
                Text(loginError)
                    .foregroundColor(.red)
                    .font(.headline)
            }

            Button {
                let cleanUsername = username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                let cleanPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
                let savedPatientUser = patientSavedUsername.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                let savedParentUser = parentSavedUsername.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

                if role == "pt" && cleanUsername == "pt" && cleanPassword == "1234" {
                    loginError = ""
                    username = ""
                    password = ""
                    screen = "ptPlan"
                } else if role == "patient" && cleanUsername == savedPatientUser && cleanPassword == patientSavedPassword {
                    loginError = ""
                    username = ""
                    password = ""
                    screen = "avatarCreator"
                } else if role == "parent" && cleanUsername == savedParentUser && cleanPassword == parentSavedPassword {
                    loginError = ""
                    username = ""
                    password = ""
                    screen = "parentCheckIn"
                } else {
                    loginError = "Invalid login"
                }
            } label: {
                Text("Log In").mainButton(color: .cyan)
            }

            if role == "patient" || role == "parent" {
                Button {
                    username = ""
                    password = ""
                    loginError = ""
                    screen = "signup"
                } label: {
                    Text("First Time User: Create Account").mainButton(color: .orange)
                }
            }

            Button {
                screen = "welcome"
                username = ""
                password = ""
                loginError = ""
            } label: {
                Text("Back").mainButton(color: .gray)
            }
        }
        .padding(.horizontal, 28)
    }
}

struct SignUpScreen: View {
    @Binding var screen: String
    let role: String
    @Binding var patientSavedUsername: String
    @Binding var patientSavedPassword: String
    @Binding var parentSavedUsername: String
    @Binding var parentSavedPassword: String

    @State private var newUsername = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var signUpError = ""

    var title: String {
        role == "parent" ? "Create Parent Account" : "Create Patient Account"
    }

    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.system(size: 31, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text("Set a username and password for first-time login.")
                .foregroundColor(.white.opacity(0.78))
                .multilineTextAlignment(.center)

            TextField("Create Username", text: $newUsername)
                .textFieldStyleCustom()

            SecureField("Create Password", text: $newPassword)
                .textFieldStyleCustom()

            SecureField("Confirm Password", text: $confirmPassword)
                .textFieldStyleCustom()

            if !signUpError.isEmpty {
                Text(signUpError)
                    .foregroundColor(.red)
                    .font(.headline)
                    .multilineTextAlignment(.center)
            }

            Button {
                let cleanUsername = newUsername.trimmingCharacters(in: .whitespacesAndNewlines)
                let cleanPassword = newPassword.trimmingCharacters(in: .whitespacesAndNewlines)
                let cleanConfirm = confirmPassword.trimmingCharacters(in: .whitespacesAndNewlines)

                if cleanUsername.count < 3 {
                    signUpError = "Username must be at least 3 characters."
                } else if cleanPassword.count < 4 {
                    signUpError = "Password must be at least 4 characters."
                } else if cleanPassword != cleanConfirm {
                    signUpError = "Passwords do not match."
                } else {
                    if role == "parent" {
                        parentSavedUsername = cleanUsername
                        parentSavedPassword = cleanPassword
                    } else {
                        patientSavedUsername = cleanUsername
                        patientSavedPassword = cleanPassword
                    }
                    signUpError = ""
                    screen = "login"
                }
            } label: {
                Text("Create Account").mainButton(color: .cyan)
            }

            Button {
                screen = "login"
            } label: {
                Text("Back to Login").mainButton(color: .gray)
            }
        }
        .padding(.horizontal, 28)
    }
}
struct TherapistNotesScreen: View {
    @Binding var screen: String
    @Binding var therapistNotes: String

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Button { screen = "welcome" } label: {
                    Text("← Back")
                        .foregroundColor(.white)
                        .font(.headline)
                }
                Spacer()
            }
            .padding(.horizontal, 22)
            .padding(.top, 75)

            Text("Therapist Notes")
                .font(.system(size: 34, weight: .black, design: .rounded))
                .foregroundColor(.white)

            Text("Comments, reminders, and safety notes from the PT.")
                .foregroundColor(.white.opacity(0.78))
                .multilineTextAlignment(.center)

            TextEditor(text: $therapistNotes)
                .frame(height: 360)
                .padding(12)
                .background(.white.opacity(0.92))
                .cornerRadius(18)
                .foregroundColor(.black)

            Button { screen = "welcome" } label: {
                Text("Save Notes").mainButton(color: .cyan)
            }

            Spacer()
        }
        .padding(.horizontal, 22)
    }
}

struct ParentCheckInScreen: View {
    @Binding var screen: String
    let plan: TreatmentPlan
    let currentSession: Int
    let currentPlanetIndex: Int
    let missionTimeRemaining: Int
    @Binding var parentCheckInNote: String

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                HStack {
                    Button { screen = "welcome" } label: {
                        Text("← Back")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    Spacer()
                }

                Text("Parent Check-In")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundColor(.white)

                Text("Quick view for parents to confirm the patient is staying on track.")
                    .foregroundColor(.white.opacity(0.78))
                    .multilineTextAlignment(.center)

                ParentStatusCard(title: "Current Session", value: "Session \(currentSession) of 3")
                ParentStatusCard(title: "Current Planet", value: planetName(currentPlanetIndex))
                ParentStatusCard(title: "Plan Status", value: plan.isLocked ? "PT plan locked" : "PT plan not locked yet")
                ParentStatusCard(title: "Targets", value: "S1: \(plan.session1Angle)°   S2: \(plan.session2Angle)°   S3: \(plan.session3Angle)°")
                ParentStatusCard(title: "Hold Time", value: "\(plan.holdMinutes) minutes per session")
                ParentStatusCard(title: "Mission Timer", value: "\(missionTimeRemaining / 60):\(String(format: "%02d", missionTimeRemaining % 60)) remaining")

                VStack(alignment: .leading, spacing: 8) {
                    Text("Parent Note")
                        .foregroundColor(.white)
                        .font(.headline)

                    TextEditor(text: $parentCheckInNote)
                        .frame(height: 130)
                        .padding(10)
                        .background(.white.opacity(0.92))
                        .cornerRadius(16)
                        .foregroundColor(.black)
                }
                .padding(14)
                .background(.black.opacity(0.36))
                .cornerRadius(20)

                Button { screen = "welcome" } label: {
                    Text("Save Check-In").mainButton(color: .purple)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 75)
            .padding(.bottom, 120)
        }
    }
}

struct ParentStatusCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .foregroundColor(.cyan)
                .font(.subheadline.bold())
            Text(value)
                .foregroundColor(.white)
                .font(.headline)
        }
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.black.opacity(0.36))
        .cornerRadius(18)
    }
}

// MARK: - Avatar / Rocket Creator

struct AvatarCreatorScreen: View {
    @Binding var screen: String
    @Binding var avatar: AvatarProfile

    let eyeOptions: [Color] = [.brown, .blue, .gray, .black]
    let suitOptions: [Color] = [.white, .gray, .blue, .black, .red, .purple]
    let stripeOptions: [Color] = [.blue, .red, .orange, .purple, .cyan, .yellow]
    let panelOptions: [Color] = [.black, .gray, .blue, .purple]
    let gloveBootOptions: [Color] = [.black, .white, .blue, .red, .orange]
    let patchOptions: [Color] = [.orange, .yellow, .cyan, .purple]

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Button { screen = "login" } label: {
                    Text("← Back")
                        .foregroundColor(.white)
                        .font(.subheadline.bold())
                }
                Spacer()
            }

            Text("Create Your Astronaut")
                .font(.system(size: 23, weight: .black, design: .rounded))
                .foregroundColor(.white)

            AstronautView(avatar: avatar)
                .scaleEffect(0.55)
                .frame(width: 135, height: 145)
                .frame(maxWidth: .infinity)
                .background(.white.opacity(0.10))
                .cornerRadius(18)

            CompactColorSelector(title: "Eyes", colors: eyeOptions, selected: $avatar.eyeColor)
            CompactColorSelector(title: "Suit", colors: suitOptions, selected: $avatar.suitBaseColor)
            CompactColorSelector(title: "Stripes", colors: stripeOptions, selected: $avatar.suitStripeColor)
            CompactColorSelector(title: "Panel", colors: panelOptions, selected: $avatar.chestPanelColor)
            CompactColorSelector(title: "Boots", colors: gloveBootOptions, selected: $avatar.gloveBootColor)
            CompactColorSelector(title: "Patch", colors: patchOptions, selected: $avatar.patchColor)

            Button {
                screen = "rocketCreator"
            } label: {
                Text("Next: Customize Rocket").mainButton(color: .cyan)
            }
        }
        .padding(.horizontal, 22)
        .padding(.top, 85)
    }
}

struct RocketCreatorScreen: View {
    @Binding var screen: String
    @Binding var avatar: AvatarProfile

    let bodyOptions: [Color] = [.white, .gray, .blue, .black, .purple]
    let noseOptions: [Color] = [.red, .blue, .orange, .green, .purple, .cyan, .yellow]
    let finOptions: [Color] = [.red, .blue, .orange, .green, .purple, .black]
    let windowOptions: [Color] = [.cyan, .blue, .purple, .orange]

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Button { screen = "avatarCreator" } label: {
                    Text("← Back")
                        .foregroundColor(.white)
                        .font(.subheadline.bold())
                }
                Spacer()
            }

            Text("Customize Your Rocket")
                .font(.system(size: 25, weight: .black, design: .rounded))
                .foregroundColor(.white)

            RocketView(
                bodyColor: avatar.rocketBodyColor,
                noseColor: avatar.rocketNoseColor,
                finColor: avatar.rocketFinColor,
                windowColor: avatar.rocketWindowColor,
                showAstronaut: true,
                skinColor: avatar.skinColor,
                eyeColor: avatar.eyeColor
            )
            .scaleEffect(1.08)
            .frame(width: 150, height: 235)
            .frame(maxWidth: .infinity)
            .background(.white.opacity(0.10))
            .cornerRadius(22)

            CompactColorSelector(title: "Body", colors: bodyOptions, selected: $avatar.rocketBodyColor)
            CompactColorSelector(title: "Nose", colors: noseOptions, selected: $avatar.rocketNoseColor)
            CompactColorSelector(title: "Fins", colors: finOptions, selected: $avatar.rocketFinColor)
            CompactColorSelector(title: "Window", colors: windowOptions, selected: $avatar.rocketWindowColor)

            Button { screen = "patientDashboard" } label: {
                Text("Save Mission Gear").mainButton(color: .cyan)
            }

            Button { screen = "avatarCreator" } label: {
                Text("Back to Astronaut").mainButton(color: .gray)
            }
        }
        .padding(.horizontal, 22)
        .padding(.top, 85)
    }
}

struct CompactColorSelector: View {
    let title: String
    let colors: [Color]
    @Binding var selected: Color

    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.white)
                .font(.system(size: 14, weight: .bold))
                .frame(width: 60, alignment: .leading)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(0..<colors.count, id: \.self) { index in
                        Circle()
                            .fill(colors[index])
                            .frame(width: 26, height: 26)
                            .overlay(Circle().stroke(Color.white, lineWidth: selected == colors[index] ? 3 : 1))
                            .onTapGesture { selected = colors[index] }
                    }
                }
            }
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 6)
        .background(.white.opacity(0.10))
        .cornerRadius(14)
    }
}

// MARK: - PT Plan

struct PTPlanScreen: View {
    @Binding var screen: String
    @Binding var plan: TreatmentPlan

    @State private var showUnlock = false
    @State private var unlockPassword = ""
    @State private var unlockError = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text("PT Treatment Plan")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(.white)

                Text("Only the physical therapist can edit and lock prescribed targets.")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.75))
                    .multilineTextAlignment(.center)

                CompactPlanInput(title: "Session 1 Target", value: $plan.session1Angle, locked: plan.isLocked, unit: "°")
                CompactPlanInput(title: "Session 2 Target", value: $plan.session2Angle, locked: plan.isLocked, unit: "°")
                CompactPlanInput(title: "Session 3 Target", value: $plan.session3Angle, locked: plan.isLocked, unit: "°")
                CompactPlanInput(title: "Hold Time", value: $plan.holdMinutes, locked: plan.isLocked, unit: " min")

                if plan.isLocked {
                    Text("Treatment Plan Locked")
                        .foregroundColor(.green)
                        .font(.headline)
                }

                Button { plan.isLocked = true } label: {
                    Text(plan.isLocked ? "Plan Already Locked" : "Lock Treatment Plan")
                        .mainButton(color: plan.isLocked ? .gray : .green)
                }
                .disabled(plan.isLocked)

                if plan.isLocked {
                    Button { showUnlock.toggle() } label: {
                        Text("Unlock with PT Password").mainButton(color: .orange)
                    }
                }

                if showUnlock {
                    SecureField("PT Password", text: $unlockPassword)
                        .textFieldStyleCustom()

                    if !unlockError.isEmpty {
                        Text(unlockError).foregroundColor(.red)
                    }

                    Button {
                        if unlockPassword == "1234" {
                            plan.isLocked = false
                            showUnlock = false
                            unlockPassword = ""
                            unlockError = ""
                        } else {
                            unlockError = "Incorrect PT password"
                        }
                    } label: {
                        Text("Confirm Unlock").mainButton(color: .red)
                    }
                }

                Button { screen = "patientDashboard" } label: {
                    Text("View Patient Dashboard").mainButton(color: .blue)
                }

                Button { screen = "welcome" } label: {
                    Text("Log Out").mainButton(color: .gray)
                }
            }
            .padding(.horizontal, 28)
            .padding(.top, 55)
            .padding(.bottom, 140)
        }
    }
}

struct CompactPlanInput: View {
    let title: String
    @Binding var value: Int
    let locked: Bool
    let unit: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .foregroundColor(.white)
                .font(.subheadline.bold())

            HStack {
                Text("\(value)\(unit)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                Button { if value > 1 { value -= 1 } } label: {
                    Text("−").miniButton()
                }
                .disabled(locked)

                Button { if value < 180 { value += 1 } } label: {
                    Text("+").miniButton()
                }
                .disabled(locked)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(.white.opacity(0.13))
            .cornerRadius(16)
        }
    }
}

// MARK: - Dashboard

struct PatientDashboard: View {
    @Binding var screen: String
    let plan: TreatmentPlan
    let avatar: AvatarProfile
    let currentSession: Int
    let currentPlanetIndex: Int
    let isPTView: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                Text("Mission Dashboard")
                    .font(.system(size: 31, weight: .black, design: .rounded))
                    .foregroundColor(.white)

                HStack(spacing: 22) {
                    AstronautView(avatar: avatar)
                        .scaleEffect(0.40)
                        .frame(width: 105, height: 135)

                    RocketView(
                        bodyColor: avatar.rocketBodyColor,
                        noseColor: avatar.rocketNoseColor,
                        finColor: avatar.rocketFinColor,
                        windowColor: avatar.rocketWindowColor,
                        showAstronaut: true,
                        skinColor: avatar.skinColor,
                        eyeColor: avatar.eyeColor
                    )
                    .frame(width: 75, height: 135)
                }
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity)
                .background(.white.opacity(0.12))
                .cornerRadius(20)

                Text(plan.isLocked ? "Locked treatment plan" : "Plan not locked yet")
                    .foregroundColor(plan.isLocked ? .green : .orange)
                    .font(.subheadline.bold())

                Text("Current Destination: \(planetName(currentPlanetIndex))")
                    .foregroundColor(.cyan)
                    .font(.subheadline.bold())

                Text("Session \(currentSession) of 3")
                    .foregroundColor(.white.opacity(0.8))
                    .font(.caption)

                SessionCard(session: 1, angle: plan.session1Angle, hold: plan.holdMinutes, planet: "Aurora Shores")
                SessionCard(session: 2, angle: plan.session2Angle, hold: plan.holdMinutes, planet: "Oceanus Prime")
                SessionCard(session: 3, angle: plan.session3Angle, hold: plan.holdMinutes, planet: "Nebula Ridge")

                if isPTView {
                    Text("PT view only — treatment must be started by the patient.")
                        .font(.caption.bold())
                        .foregroundColor(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .background(.black.opacity(0.35))
                        .cornerRadius(14)

                    Button { screen = "ptPlan" } label: {
                        Text("Back to PT Plan").mainButton(color: .blue)
                    }
                } else {
                    Button { screen = "rocketFueling" } label: {
                        Text("Start Assigned Mission")
                            .mainButton(color: plan.isLocked ? .cyan : .gray)
                    }
                    .disabled(!plan.isLocked)

                    Button { screen = "avatarCreator" } label: {
                        Text("Edit Mission Gear").mainButton(color: .orange)
                    }
                }

                Button { screen = "welcome" } label: {
                    Text("Log Out").mainButton(color: .gray)
                }
            }
            .padding(.horizontal, 28)
            .padding(.top, 55)
            .padding(.bottom, 140)
        }
    }
}

struct SessionCard: View {
    let session: Int
    let angle: Int
    let hold: Int
    let planet: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Session \(session): \(planet)")
                .font(.subheadline.bold())
                .foregroundColor(.white)
            Text("Target Angle: \(angle)°")
                .font(.caption)
                .foregroundColor(.white.opacity(0.85))
            Text("Mission Time: \(hold) minutes")
                .font(.caption)
                .foregroundColor(.white.opacity(0.85))
        }
        .padding(11)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.12))
        .cornerRadius(16)
    }
}

// MARK: - Rocket Fueling + Cinematics

struct RocketFuelingScreen: View {
    @Binding var screen: String
    @Binding var currentSession: Int

    let currentPlanetIndex: Int
    let plan: TreatmentPlan
    let avatar: AvatarProfile

    @State private var fuelPercent: Double = 0

    var target: Int {
        targetAngle(for: currentSession, plan: plan)
    }

    var body: some View {
        ZStack {
            if currentSession == 1 {
                EarthSkyScene().ignoresSafeArea()
            } else if currentPlanetIndex == 1 {
                OceanusPrimeScene().ignoresSafeArea()
            } else {
                CrystalLagoonScene().ignoresSafeArea()
            }

            VStack {
                HStack {
                    Button { screen = "patientDashboard" } label: {
                        Text("← Back")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    Spacer()
                }
                .padding(.horizontal, 22)
                .padding(.top, 75)

                Spacer()

                RocketView(
                    bodyColor: avatar.rocketBodyColor,
                    noseColor: avatar.rocketNoseColor,
                    finColor: avatar.rocketFinColor,
                    windowColor: avatar.rocketWindowColor,
                    showAstronaut: true,
                    skinColor: avatar.skinColor,
                    eyeColor: avatar.eyeColor
                )
                .scaleEffect(1.85)
                .frame(height: 290)

                Spacer()

                VStack(spacing: 12) {
                    Text("Session \(currentSession) Target: \(target)°")
                        .foregroundColor(.white)
                        .font(.title3.bold())

                    ProgressView(value: fuelPercent, total: 100)
                        .tint(.cyan)
                        .scaleEffect(x: 1, y: 2.4)

                    Text("Rocket Fuel: \(Int(fuelPercent))%")
                        .foregroundColor(.cyan)
                        .font(.title2.bold())

                    Button {
                        withAnimation(.easeInOut(duration: 0.35)) {
                            fuelPercent = min(fuelPercent + 25, 100)
                        }

                        if fuelPercent >= 100 {
                            if currentSession == 1 {
                                screen = "earthLaunch"
                            } else {
                                screen = "missionChoice"
                            }
                        }
                    } label: {
                        Text(fuelPercent >= 100 ? "Launch Rocket" : "Fuel Rocket")
                            .mainButton(color: .cyan)
                    }
                }
                .padding(22)
                .background(.black.opacity(0.45))
                .cornerRadius(28)
                .padding(.horizontal, 22)
                .padding(.bottom, 28)
            }
        }
    }
}

struct EarthLaunchScreen: View {
    @Binding var screen: String
    let avatar: AvatarProfile

    @State private var liftOff = false
    @State private var flamePulse = false
    @State private var smoke = false

    var body: some View {
        ZStack {
            EarthSkyScene()

            VStack {
                Spacer()

                RocketView(
                    bodyColor: avatar.rocketBodyColor,
                    noseColor: avatar.rocketNoseColor,
                    finColor: avatar.rocketFinColor,
                    windowColor: avatar.rocketWindowColor,
                    showAstronaut: true,
                    skinColor: avatar.skinColor,
                    eyeColor: avatar.eyeColor
                )
                .scaleEffect(1.45)
                .offset(y: liftOff ? -720 : -80)
                .animation(.easeInOut(duration: 3.4), value: liftOff)

                ZStack {
                    Flame()
                        .fill(LinearGradient(colors: [.yellow, .orange, .red], startPoint: .top, endPoint: .bottom))
                        .frame(width: flamePulse ? 105 : 65, height: flamePulse ? 220 : 140)
                        .blur(radius: 2)

                    ForEach(0..<16, id: \.self) { _ in
                        Circle()
                            .fill(.gray.opacity(0.38))
                            .frame(width: smoke ? CGFloat.random(in: 35...105) : 14)
                            .blur(radius: 12)
                            .offset(x: CGFloat.random(in: -150...150), y: smoke ? CGFloat.random(in: 40...170) : 50)
                    }
                }
                .offset(y: liftOff ? -720 : -35)

                Spacer().frame(height: 70)
            }

            VStack {
                Text("Launch From Earth")
                    .font(.system(size: 31, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 75)
                Spacer()
                Text("Target reached. Launch clearance granted.")
                    .foregroundColor(.green)
                    .font(.headline)
                    .padding(.bottom, 28)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 0.35).repeatForever(autoreverses: true)) {
                flamePulse = true
            }
            withAnimation(.easeOut(duration: 2.0)) {
                smoke = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                liftOff = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                screen = "spaceTravel"
            }
        }
    }
}

struct SpaceTravelScreen: View {
    @Binding var screen: String
    let avatar: AvatarProfile

    @State private var moveStars = false
    @State private var rocketGlide = false

    var body: some View {
        ZStack {
            SpaceFlightScene(moveStars: moveStars)
            TravelingPlanetField(animate: moveStars)

            RocketView(
                bodyColor: avatar.rocketBodyColor,
                noseColor: avatar.rocketNoseColor,
                finColor: avatar.rocketFinColor,
                windowColor: avatar.rocketWindowColor,
                showAstronaut: true,
                skinColor: avatar.skinColor,
                eyeColor: avatar.eyeColor
            )
            .scaleEffect(1.05)
            .rotationEffect(.degrees(35))
            .offset(x: rocketGlide ? 90 : -90, y: rocketGlide ? -60 : 80)
            .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: rocketGlide)

            VStack {
                Text("Traveling Through Space")
                    .font(.system(size: 29, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 75)
                Spacer()
                Text("Approaching \(planetName(0))")
                    .foregroundColor(.cyan)
                    .font(.headline)
                    .padding(.bottom, 30)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            moveStars = true
            rocketGlide = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.2) {
                screen = "planetArrival"
            }
        }
    }
}

struct PlanetArrivalScreen: View {
    @Binding var screen: String
    let avatar: AvatarProfile
    let planetIndex: Int
    let currentSession: Int
    let plan: TreatmentPlan

    @State private var glow = false
    @State private var landingAngle: Double = 0
    @State private var landingComplete = false
    @State private var burst = false

    var target: Int {
        targetAngle(for: currentSession, plan: plan)
    }

    var landingProgress: Double {
        if target <= 0 { return 0 }
        return min(max(landingAngle / Double(target), 0), 1)
    }

    var rocketX: CGFloat {
        CGFloat(135 - (135 * landingProgress))
    }

    var rocketY: CGFloat {
        CGFloat(-210 + (460 * landingProgress))
    }

    var rocketRotation: Double {
        -18 + (18 * landingProgress)
    }

    var body: some View {
        ZStack {
            if planetIndex == 1 {
                OceanusPrimeScene()
            } else {
                CrystalLagoonScene()
            }

            if landingComplete {
                FireworksView(burst: burst)
            }

            RocketView(
                bodyColor: avatar.rocketBodyColor,
                noseColor: avatar.rocketNoseColor,
                finColor: avatar.rocketFinColor,
                windowColor: avatar.rocketWindowColor,
                showAstronaut: true,
                skinColor: avatar.skinColor,
                eyeColor: avatar.eyeColor
            )
            .scaleEffect(0.9)
            .offset(x: rocketX, y: rocketY)
            .rotationEffect(.degrees(rocketRotation))
            .shadow(color: .cyan.opacity(glow ? 0.9 : 0.25), radius: glow ? 30 : 8)
            .animation(.easeInOut(duration: 1.6), value: landingAngle)

            VStack(spacing: 10) {
                Text(planetName(planetIndex))
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 130)

                Text(planetSubtitle(planetIndex))
                    .font(.headline.bold())
                    .foregroundColor(.cyan.opacity(0.9))

                Spacer()

                VStack(spacing: 10) {
                    Text(landingComplete ? "Congrats! You completed your first landing alignment." : "Landing Alignment")
                        .font(.headline)
                        .foregroundColor(landingComplete ? .yellow : .white)
                        .multilineTextAlignment(.center)

                    Text("Angle: \(Int(landingAngle))° / \(target)°")
                        .font(.title3.bold())
                        .foregroundColor(.cyan)

                    Text("Turn the BOA dial to guide the rocket landing.")
                        .foregroundColor(.mint)
                        .font(.caption.bold())
                        .multilineTextAlignment(.center)

                    Slider(value: Binding(
                        get: { landingAngle },
                        set: { newValue in
                            landingAngle = newValue
                            if newValue >= Double(target) && !landingComplete {
                                landingComplete = true
                                burst = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                    if planetIndex == 0 && currentSession == 1 {
                                        screen = "landingCongrats"
                                    } else if planetIndex == 1 {
                                        screen = "secondLandingCongrats"
                                    } else {
                                        screen = "missionChoice"
                                    }
                                }
                            }
                        }
                    ), in: 0...Double(target), step: 1)
                    .tint(.mint)

                    if !landingComplete {
                        Text("Start at 0° and slowly turn the dial as the rocket lands.")
                            .foregroundColor(.white.opacity(0.82))
                            .font(.caption)
                    }
                }
                .padding(18)
                .background(.black.opacity(0.45))
                .cornerRadius(24)
                .padding(.horizontal, 22)
                .padding(.bottom, 28)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            landingAngle = 0
            landingComplete = false
            burst = false
            withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                glow = true
            }
        }
    }
}


// MARK: - Crossing Deep Space Scene

struct CrossingDeepSpaceScene: View {
    let animate: Bool

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.black,
                    Color(red: 0.02, green: 0.02, blue: 0.18),
                    Color(red: 0.08, green: 0.00, blue: 0.22)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            ForEach(0..<120, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(index % 3 == 0 ? 0.95 : 0.55))
                    .frame(
                        width: CGFloat.random(in: 1.4...4.4),
                        height: CGFloat.random(in: 1.4...4.4)
                    )
                    .position(
                        x: CGFloat.random(in: 0...390),
                        y: animate ? CGFloat.random(in: 760...1200) : CGFloat.random(in: -160...760)
                    )
                    .animation(
                        .linear(duration: Double.random(in: 2.5...5.8))
                        .repeatForever(autoreverses: false),
                        value: animate
                    )
            }

            Circle()
                .fill(
                    LinearGradient(
                        colors: [.purple, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 125, height: 125)
                .position(x: 315, y: 160)
                .shadow(color: .purple.opacity(0.7), radius: 22)

            Circle()
                .fill(
                    LinearGradient(
                        colors: [.orange, .yellow],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 62, height: 62)
                .position(x: 78, y: 330)
                .shadow(color: .orange.opacity(0.65), radius: 16)

            Circle()
                .fill(
                    LinearGradient(
                        colors: [.cyan, .mint],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 45, height: 45)
                .position(x: 330, y: 540)
                .shadow(color: .cyan.opacity(0.55), radius: 14)

            ForEach(0..<7, id: \.self) { index in
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0), .cyan.opacity(0.9)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 105, height: 3)
                    .rotationEffect(.degrees(-28))
                    .offset(
                        x: animate ? 290 : -280,
                        y: CGFloat(-280 + index * 135)
                    )
                    .animation(
                        .linear(duration: Double(2.6 + Double(index) * 0.32))
                        .repeatForever(autoreverses: false),
                        value: animate
                    )
            }
        }
        .ignoresSafeArea()
    }
}






// MARK: - Aurora To Oceanus Crossing Deep Space

struct AuroraToOceanusDeepSpaceScene: View {
    let animate: Bool
    @State private var run = false

    var body: some View {
        ZStack {
            // Same moving star background style used during launch/travel to Aurora Shores
            SpaceFlightScene(moveStars: run)

            // Cinematic nebula glow
            RadialGradient(
                colors: [
                    Color.purple.opacity(0.50),
                    Color.blue.opacity(0.25),
                    Color.clear
                ],
                center: .center,
                startRadius: 20,
                endRadius: 330
            )
            .offset(x: -35, y: 110)
            .blur(radius: 18)

            RadialGradient(
                colors: [
                    Color.cyan.opacity(0.34),
                    Color.clear
                ],
                center: .bottomTrailing,
                startRadius: 10,
                endRadius: 290
            )
            .blur(radius: 18)

            // Purple / blue glowing planet
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.purple, .blue, .indigo],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Circle()
                    .stroke(Color.purple.opacity(0.75), lineWidth: 4)
                    .blur(radius: 1)

                Ellipse()
                    .stroke(Color.purple.opacity(0.65), lineWidth: 3)
                    .frame(width: 170, height: 45)
                    .rotationEffect(.degrees(-20))
            }
            .frame(width: 128, height: 128)
            .position(x: 315, y: 175)
            .shadow(color: .purple.opacity(0.9), radius: 28)

            // Orange / yellow glowing planet
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.orange, .yellow],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 68, height: 68)
                .position(x: 76, y: 335)
                .shadow(color: .orange.opacity(0.85), radius: 22)

            // Cyan glowing planet
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.cyan, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Ellipse()
                    .stroke(Color.cyan.opacity(0.75), lineWidth: 2)
                    .frame(width: 82, height: 24)
                    .rotationEffect(.degrees(-18))
            }
            .frame(width: 58, height: 58)
            .position(x: 322, y: 560)
            .shadow(color: .cyan.opacity(0.9), radius: 22)

            // Moving light streaks / comet trails
            ForEach(0..<18, id: \.self) { index in
                let yPos = CGFloat(55 + index * 42)
                let width = CGFloat(95 + (index % 4) * 22)
                let height = CGFloat(index % 3 == 0 ? 4 : 3)
                let startX = CGFloat(-180 - index * 18)
                let endX = CGFloat(450 + index * 12)

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.0),
                                index % 2 == 0 ? Color.cyan.opacity(0.95) : Color.purple.opacity(0.95),
                                Color.white.opacity(0.85)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: width, height: height)
                    .rotationEffect(.degrees(-28))
                    .position(
                        x: run ? endX : startX,
                        y: yPos
                    )
                    .animation(
                        .linear(duration: Double(1.8 + Double(index % 6) * 0.32))
                        .repeatForever(autoreverses: false),
                        value: run
                    )
            }

            // Small spaceship silhouettes
            ForEach(0..<4, id: \.self) { index in
                let size = CGFloat(18 + index * 3)
                let startX = CGFloat(-260 - index * 55)
                let endX = CGFloat(260 + index * 45)
                let yPos = CGFloat(120 + index * 150)

                Image(systemName: "paperplane.fill")
                    .font(.system(size: size))
                    .foregroundColor(Color.white.opacity(0.55))
                    .rotationEffect(.degrees(-30))
                    .position(
                        x: run ? endX : startX,
                        y: yPos
                    )
                    .animation(
                        .linear(duration: Double(4 + index))
                        .repeatForever(autoreverses: false),
                        value: run
                    )
            }

            VStack(spacing: 8) {
                Text("Crossing Deep Space")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .cyan.opacity(0.9), radius: 12)
                    .multilineTextAlignment(.center)

                Text("Leaving Aurora Shores → Oceanus Prime")
                    .font(.headline.bold())
                    .foregroundColor(.cyan)
                    .shadow(radius: 6)
                    .multilineTextAlignment(.center)

                Spacer()

                Text("Plotting course to Oceanus Prime...")
                    .font(.headline.bold())
                    .foregroundColor(.cyan)
                    .padding(.bottom, 42)
            }
            .padding(.top, 95)
            .padding(.horizontal, 20)
        }
        .ignoresSafeArea()
        .onAppear {
            run = true
        }
    }
}



struct PlanetTransitScreen: View {
    @Binding var screen: String
    @Binding var currentSession: Int
    @Binding var currentPlanetIndex: Int
    let avatar: AvatarProfile

    @State private var phase = 0
    @State private var rocketMove = false

    var nextPlanetIndex: Int {
        min(currentPlanetIndex + 1, 2)
    }

    var body: some View {
        ZStack {
            if phase < 2 {
                currentPlanetIndex == 0 ? AnyView(CrystalLagoonScene()) : AnyView(OceanusPrimeScene())
            } else if phase < 4 {
                AuroraToOceanusDeepSpaceScene(animate: true)
            } else {
                nextPlanetIndex == 1 ? AnyView(OceanusPrimeScene()) : AnyView(NebulaRidgeScene())
            }

            RocketView(
                bodyColor: avatar.rocketBodyColor,
                noseColor: avatar.rocketNoseColor,
                finColor: avatar.rocketFinColor,
                windowColor: avatar.rocketWindowColor,
                showAstronaut: true,
                skinColor: avatar.skinColor,
                eyeColor: avatar.eyeColor
            )
            .scaleEffect(phase < 4 ? 1.0 : 0.9)
            .rotationEffect(.degrees(phase == 2 || phase == 3 ? 35 : 0))
            .offset(
                x: phase == 2 || phase == 3 ? (rocketMove ? 105 : -105) : 0,
                y: phase == 0 ? 230 : phase == 1 ? -420 : phase == 4 ? (rocketMove ? 250 : -340) : 0
            )
            .animation(.easeInOut(duration: 2.0), value: phase)
            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: rocketMove)

            VStack {
                Text(phase < 2 ? "Leaving \(planetName(currentPlanetIndex))" : phase < 4 ? "" : "Arriving at Oceanus Prime")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 80)
                    .shadow(radius: 8)

                Spacer()

                Text(phase < 2 ? "Launching from Aurora Shores" : phase < 4 ? "" : "Prepare for Oceanus Prime landing")
                    .font(.headline)
                    .foregroundColor(.cyan)
                    .padding(.bottom, 35)
                    .shadow(radius: 5)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            rocketMove = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) { phase = 1 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) { phase = 2 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.4) { phase = 3 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 7.2) { phase = 4 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 9.4) {
                currentPlanetIndex = nextPlanetIndex
                currentSession = min(currentSession + 1, 3)
                screen = "planetArrival"
            }
        }
    }
}

// MARK: - Mission Choice + Games

struct MissionChoiceScreen: View {
    @Binding var screen: String
    let currentPlanetIndex: Int
    let plan: TreatmentPlan
    @Binding var missionTimeRemaining: Int
    @Binding var timerRunning: Bool

    var body: some View {
        ZStack {
            if currentPlanetIndex == 1 {
                OceanusPrimeScene().ignoresSafeArea()
            } else {
                CrystalLagoonScene().ignoresSafeArea()
            }

            VStack {
                VStack(spacing: 4) {
                    Text(planetName(currentPlanetIndex))
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(radius: 8)

                    Text(planetSubtitle(currentPlanetIndex))
                        .font(.title3.bold())
                        .foregroundColor(.cyan)
                        .shadow(radius: 5)
                }
                .padding(.top, 85)

                Spacer()

                VStack(spacing: 12) {
                    Text("Choose your mission activity")
                        .foregroundColor(.white)
                        .font(.headline)
                        .shadow(radius: 5)

                    if currentPlanetIndex == 1 {
                        Button { screen = "treasureHunt" } label: {
                            Text("Deep Sea Treasure Hunt").mainButton(color: .blue)
                        }
                        Button { screen = "reefBuilder" } label: {
                            Text("Reef Builder").mainButton(color: .purple)
                        }
                    } else {
                        GamePreviewCard(
                            title: "Alien Fishing",
                            subtitle: "Move the hook and catch alien fish.",
                            emoji: "🎣",
                            color: .blue
                        )

                        Button { screen = "alienFishing" } label: {
                            Text("Play Alien Fishing").mainButton(color: .blue)
                        }

                        GamePreviewCard(
                            title: "Space Snake Rescue",
                            subtitle: "Guide the snake to collect glowing crystals.",
                            emoji: "🐍",
                            color: .purple
                        )

                        Button { screen = "crystalCollector" } label: {
                            Text("Play Space Snake Rescue").mainButton(color: .purple)
                        }
                    }

                    Button { screen = "missionTimerOnly" } label: {
                        Text("Mission Timer Only").mainButton(color: .green)
                    }
                }
                .padding(20)
                .background(.black.opacity(0.42))
                .cornerRadius(28)
                .padding(.horizontal, 22)
                .padding(.bottom, 28)
            }
        }
        .onAppear {
            if !timerRunning {
                missionTimeRemaining = plan.holdMinutes * 60
            }
        }
    }
}



// MARK: - Game Preview Card

struct GamePreviewCard: View {
    let title: String
    let subtitle: String
    let emoji: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Text(emoji)
                .font(.system(size: 34))
                .frame(width: 52, height: 52)
                .background(color.opacity(0.25))
                .cornerRadius(16)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.bold())
                    .foregroundColor(.white)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.82))
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(12)
        .background(.black.opacity(0.42))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(color.opacity(0.85), lineWidth: 1.5)
        )
        .cornerRadius(18)
    }
}


struct KeyboardInputView: UIViewControllerRepresentable {
    var onMove: (CGFloat, CGFloat) -> Void

    func makeUIViewController(context: Context) -> KeyboardInputViewController {
        let controller = KeyboardInputViewController()
        controller.onMove = onMove
        return controller
    }

    func updateUIViewController(_ uiViewController: KeyboardInputViewController, context: Context) {
        uiViewController.onMove = onMove
        DispatchQueue.main.async {
            uiViewController.becomeFirstResponder()
        }
    }
}

final class KeyboardInputViewController: UIViewController {
    var onMove: ((CGFloat, CGFloat) -> Void)?

    override var canBecomeFirstResponder: Bool { true }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
    }

    override var keyCommands: [UIKeyCommand]? {
        [
            UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags: [], action: #selector(moveUp)),
            UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags: [], action: #selector(moveDown)),
            UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags: [], action: #selector(moveLeft)),
            UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags: [], action: #selector(moveRight)),
            UIKeyCommand(input: "w", modifierFlags: [], action: #selector(moveUp)),
            UIKeyCommand(input: "W", modifierFlags: [], action: #selector(moveUp)),
            UIKeyCommand(input: "s", modifierFlags: [], action: #selector(moveDown)),
            UIKeyCommand(input: "S", modifierFlags: [], action: #selector(moveDown)),
            UIKeyCommand(input: "a", modifierFlags: [], action: #selector(moveLeft)),
            UIKeyCommand(input: "A", modifierFlags: [], action: #selector(moveLeft)),
            UIKeyCommand(input: "d", modifierFlags: [], action: #selector(moveRight)),
            UIKeyCommand(input: "D", modifierFlags: [], action: #selector(moveRight))
        ]
    }

    @objc private func moveUp() { onMove?(0, -30) }
    @objc private func moveDown() { onMove?(0, 30) }
    @objc private func moveLeft() { onMove?(-30, 0) }
    @objc private func moveRight() { onMove?(30, 0) }
}

struct AlienFishingGameScreen: View {
    @Binding var screen: String
    let avatar: AvatarProfile
    @Binding var currentSession: Int
    @Binding var currentPlanetIndex: Int
    @Binding var missionTimeRemaining: Int
    @Binding var timerRunning: Bool

    @State private var showHowToPlay = true
    @State private var hookX: CGFloat = 195
    @State private var hookY: CGFloat = 175
    @State private var isFishingActive = false
    @State private var caughtFish: Set<Int> = []
    @State private var totalScore = 0
    @State private var fishingLevel = 1
    @State private var fishGoal = 8

    var body: some View {
        ZStack {
            TinyFishingLagoonScene()

            KeyboardInputView { dx, dy in
                moveHook(dx: dx, dy: dy)
            }
            .frame(width: 1, height: 1)
            .opacity(0.01)

            TinyFishingGameScene(
                avatar: avatar,
                hookX: $hookX,
                hookY: $hookY,
                isFishingActive: isFishingActive,
                caughtFish: $caughtFish,
                totalScore: $totalScore,
                fishingLevel: fishingLevel,
                fishGoal: fishGoal
            )

            VStack {
                HStack {
                    Button { screen = "missionChoice" } label: {
                        Text("← Back")
                            .foregroundColor(.white)
                            .font(.headline)
                    }

                    Spacer()

                    Text(formatTime(missionTimeRemaining))
                        .font(.headline)
                        .foregroundColor(.cyan)
                }
                .padding(.horizontal, 22)
                .padding(.top, 75)

                VStack(spacing: 4) {
                    Text("Alien Fishing")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(radius: 6)

                    Text("Level \(fishingLevel)   Fish: \(caughtFish.count)/\(fishGoal)   Score: \(totalScore)")
                        .font(.headline)
                        .foregroundColor(.cyan)
                        .shadow(color: .black.opacity(0.8), radius: 3)
                }

                Spacer()

                VStack(spacing: 8) {
                    if !isFishingActive {
                        Button {
                            startCast()
                        } label: {
                            Text("Cast Line")
                                .mainButton(color: .blue)
                        }
                    } else {
                        Text("Move hook with ↑ ↓ ← → or W A S D")
                            .font(.headline)
                            .foregroundColor(.cyan)
                            .multilineTextAlignment(.center)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(.black.opacity(0.45))
                            .cornerRadius(15)

                        Button {
                            resetHook()
                        } label: {
                            Text("Reset Hook")
                                .mainButton(color: .orange)
                        }
                    }

                    HStack(spacing: 8) {
                        Button { screen = "crystalCollector" } label: {
                            Text("Snake")
                                .mainButton(color: .purple)
                        }

                        Button { screen = "missionTimerOnly" } label: {
                            Text("Timer")
                                .mainButton(color: .green)
                        }
                    }

                    Button { finishSession() } label: {
                        Text("Finish Session")
                            .mainButton(color: .green)
                    }
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 28)
            }

            if showHowToPlay {
                HowToPlayPopup(
                    title: "How to Play",
                    message: "Tap Cast Line, then use the keyboard arrows or W A S D to move the hook. Fish collect automatically when the hook touches them. Catch all fish to unlock the next fishing level. The mission timer keeps running.",
                    buttonText: "Start Fishing",
                    closeAction: { showHowToPlay = false }
                )
            }
        }
        .ignoresSafeArea()
        .onAppear {
            timerRunning = true
            resetHook()
        }
        .onChange(of: caughtFish.count) { _, newCount in
            if newCount >= fishGoal {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    checkNextFishingLevel()
                }
            }
        }
    }

    func startCast() {
        isFishingActive = true
        hookX = 195
        hookY = 360
    }

    func moveHook(dx: CGFloat, dy: CGFloat) {
        if isFishingActive {
            withAnimation(.easeOut(duration: 0.12)) {
                hookX = min(max(hookX + dx, 35), 355)
                hookY = min(max(hookY + dy, 175), 690)
            }
        }
    }

    func checkNextFishingLevel() {
        if caughtFish.count >= fishGoal {
            fishingLevel += 1
            fishGoal += 4
            caughtFish.removeAll()
            hookX = 195
            hookY = 360
            isFishingActive = true
        }
    }

    func resetHook() {
        hookX = 195
        hookY = 175
        isFishingActive = false
    }

    func finishSession() {
        timerRunning = false
        screen = "missionComplete"
    }

    func formatTime(_ seconds: Int) -> String {
        "\(seconds / 60):\(String(format: "%02d", seconds % 60))"
    }
}


struct CrystalCollectorGameScreen: View {
    @Binding var screen: String
    @Binding var currentSession: Int
    @Binding var currentPlanetIndex: Int
    @Binding var missionTimeRemaining: Int
    @Binding var timerRunning: Bool

    struct SnakeGridPoint: Hashable {
        let x: Int
        let y: Int
    }

    @State private var showHowToPlay = true
    @State private var snake: [SnakeGridPoint] = [
        SnakeGridPoint(x: 5, y: 5),
        SnakeGridPoint(x: 4, y: 5),
        SnakeGridPoint(x: 3, y: 5)
    ]
    @State private var food = SnakeGridPoint(x: 9, y: 9)
    @State private var directionX = 1
    @State private var directionY = 0
    @State private var pendingDirectionX = 1
    @State private var pendingDirectionY = 0
    @State private var score = 0
    @State private var level = 1
    @State private var gameOver = false
    @State private var lastMoveTime = Date.distantPast

    let gridSize = 12

    var moveDelay: TimeInterval {
        max(0.13, 0.48 - Double(level - 1) * 0.06)
    }

    var body: some View {
        ZStack {
            CrystalLagoonScene()

            KeyboardInputView { dx, dy in
                changeDirection(dx: dx, dy: dy)
            }
            .frame(width: 1, height: 1)
            .opacity(0.01)

            VStack {
                HStack {
                    Button {
                        screen = "missionChoice"
                    } label: {
                        Text("← Back")
                            .foregroundColor(.white)
                            .font(.headline)
                    }

                    Spacer()

                    Text(formatTime(missionTimeRemaining))
                        .font(.headline)
                        .foregroundColor(.cyan)
                }
                .padding(.horizontal, 22)
                .padding(.top, 75)

                VStack(spacing: 4) {
                    Text("Space Snake Rescue")
                        .font(
                            .system(
                                size: 30,
                                weight: .black,
                                design: .rounded
                            )
                        )
                        .foregroundColor(.white)
                        .shadow(radius: 6)

                    Text("Level \(level)   Score: \(score)   Length: \(snake.count)")
                        .font(.headline)
                        .foregroundColor(.cyan)
                        .shadow(color: .black.opacity(0.8), radius: 3)
                }

                Spacer()

                VStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 22)
                            .fill(.black.opacity(0.38))
                            .overlay(
                                RoundedRectangle(cornerRadius: 22)
                                    .stroke(.cyan.opacity(0.75), lineWidth: 2)
                            )

                        GeometryReader { geometry in
                            let cellSize = min(geometry.size.width, geometry.size.height) / CGFloat(gridSize)
                            let boardSize = cellSize * CGFloat(gridSize)
                            let xOffset = (geometry.size.width - boardSize) / 2
                            let yOffset = (geometry.size.height - boardSize) / 2

                            ZStack {
                                ForEach(0..<gridSize, id: \.self) { row in
                                    ForEach(0..<gridSize, id: \.self) { column in
                                        Rectangle()
                                            .stroke(.white.opacity(0.12), lineWidth: 0.7)
                                            .frame(width: cellSize, height: cellSize)
                                            .position(
                                                x: xOffset + CGFloat(column) * cellSize + cellSize / 2,
                                                y: yOffset + CGFloat(row) * cellSize + cellSize / 2
                                            )
                                    }
                                }

                                Circle()
                                    .fill(.yellow)
                                    .frame(width: cellSize * 0.72, height: cellSize * 0.72)
                                    .shadow(color: .yellow.opacity(0.85), radius: 10)
                                    .position(
                                        x: xOffset + CGFloat(food.x) * cellSize + cellSize / 2,
                                        y: yOffset + CGFloat(food.y) * cellSize + cellSize / 2
                                    )

                                ForEach(Array(snake.enumerated()), id: \.offset) { index, segment in
                                    RoundedRectangle(cornerRadius: cellSize * 0.28)
                                        .fill(index == 0 ? Color.green : Color.mint)
                                        .frame(width: cellSize * 0.86, height: cellSize * 0.86)
                                        .overlay(
                                            Group {
                                                if index == 0 {
                                                    HStack(spacing: cellSize * 0.12) {
                                                        Circle()
                                                            .fill(.white)
                                                        Circle()
                                                            .fill(.white)
                                                    }
                                                    .frame(width: cellSize * 0.42, height: cellSize * 0.18)
                                                }
                                            }
                                        )
                                        .shadow(color: .green.opacity(index == 0 ? 0.85 : 0.45), radius: index == 0 ? 9 : 4)
                                        .position(
                                            x: xOffset + CGFloat(segment.x) * cellSize + cellSize / 2,
                                            y: yOffset + CGFloat(segment.y) * cellSize + cellSize / 2
                                        )
                                }
                            }
                        }
                        .padding(12)

                        if gameOver {
                            VStack(spacing: 10) {
                                Text("Snake Rescue Restart")
                                    .font(.title2.bold())
                                    .foregroundColor(.white)

                                Text("Avoid the walls and your own tail.")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.white.opacity(0.85))
                                    .multilineTextAlignment(.center)

                                Button {
                                    restartGame()
                                } label: {
                                    Text("Restart Level")
                                        .mainButton(color: .orange)
                                }
                            }
                            .padding(18)
                            .background(.black.opacity(0.78))
                            .cornerRadius(22)
                            .padding(.horizontal, 18)
                        }
                    }
                    .frame(height: 360)

                    Text("Use ↑ ↓ ← → or W A S D to guide the snake.")
                        .font(.headline)
                        .foregroundColor(.cyan)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(.black.opacity(0.45))
                        .cornerRadius(15)
                }
                .padding(.horizontal, 22)

                Spacer()

                HStack(spacing: 8) {
                    Button {
                        screen = "alienFishing"
                    } label: {
                        Text("Fishing")
                            .mainButton(color: .blue)
                    }

                    Button {
                        screen = "missionTimerOnly"
                    } label: {
                        Text("Timer")
                            .mainButton(color: .green)
                    }
                }
                .padding(.horizontal, 22)

                Button {
                    finishSession()
                } label: {
                    Text("Finish Session")
                        .mainButton(color: .green)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 28)
            }

            if showHowToPlay {
                HowToPlayPopup(
                    title: "How to Play",
                    message: "Guide the space snake with the laptop arrow keys or W A S D. Eat glowing crystals to grow. Every 5 crystals increases the level and makes the snake move faster. Avoid the walls and your own tail.",
                    buttonText: "Start Snake Rescue",
                    closeAction: {
                        showHowToPlay = false
                    }
                )
            }
        }
        .ignoresSafeArea()
        .onAppear {
            timerRunning = true
            restartGame()
        }
        .onReceive(Timer.publish(every: 0.08, on: .main, in: .common).autoconnect()) { _ in
            if !showHowToPlay && !gameOver {
                let now = Date()
                if now.timeIntervalSince(lastMoveTime) >= moveDelay {
                    moveSnake()
                    lastMoveTime = now
                }
            }
        }
    }

    func changeDirection(dx: CGFloat, dy: CGFloat) {
        let newX: Int
        let newY: Int

        if abs(dx) > abs(dy) {
            newX = dx > 0 ? 1 : -1
            newY = 0
        } else {
            newX = 0
            newY = dy > 0 ? 1 : -1
        }

        if newX == -directionX && newY == -directionY {
            return
        }

        pendingDirectionX = newX
        pendingDirectionY = newY
    }

    func moveSnake() {
        directionX = pendingDirectionX
        directionY = pendingDirectionY

        guard let head = snake.first else { return }

        let newHead = SnakeGridPoint(
            x: head.x + directionX,
            y: head.y + directionY
        )

        if newHead.x < 0 || newHead.x >= gridSize || newHead.y < 0 || newHead.y >= gridSize || snake.contains(newHead) {
            gameOver = true
            return
        }

        snake.insert(newHead, at: 0)

        if newHead == food {
            score += 10

            if score % 50 == 0 {
                level += 1
            }

            placeFood()
        } else {
            snake.removeLast()
        }
    }

    func placeFood() {
        var newFood = SnakeGridPoint(
            x: Int.random(in: 0..<gridSize),
            y: Int.random(in: 0..<gridSize)
        )

        while snake.contains(newFood) {
            newFood = SnakeGridPoint(
                x: Int.random(in: 0..<gridSize),
                y: Int.random(in: 0..<gridSize)
            )
        }

        food = newFood
    }

    func restartGame() {
        snake = [
            SnakeGridPoint(x: 5, y: 5),
            SnakeGridPoint(x: 4, y: 5),
            SnakeGridPoint(x: 3, y: 5)
        ]
        food = SnakeGridPoint(x: 9, y: 9)
        directionX = 1
        directionY = 0
        pendingDirectionX = 1
        pendingDirectionY = 0
        gameOver = false
        lastMoveTime = Date()
    }

    func finishSession() {
        timerRunning = false
        screen = "missionComplete"
    }

    func formatTime(_ seconds: Int) -> String {
        "\(seconds / 60):\(String(format: "%02d", seconds % 60))"
    }
}
struct DeepSeaTreasureHuntScreen: View {
    @Binding var screen: String
    @Binding var currentSession: Int
    @Binding var currentPlanetIndex: Int
    @Binding var missionTimeRemaining: Int
    @Binding var timerRunning: Bool

    @State private var treasureMove = false
    @State private var collected: Set<Int> = []
    @State private var showHowToPlay = true

    var body: some View {
        ZStack {
            OceanusPrimeScene()

            ForEach(0..<16, id: \.self) { i in
                if !collected.contains(i) {
                    TreasureChest()
                        .frame(width: 48, height: 34)
                        .position(
                            x: CGFloat(35 + (i % 4) * 90),
                            y: treasureMove ? CGFloat(170 + (i / 4) * 120) : CGFloat(700 - (i / 4) * 90)
                        )
                        .animation(.easeInOut(duration: Double(2.4 + Double(i % 4) * 0.4)).repeatForever(autoreverses: true), value: treasureMove)
                        .onTapGesture { collected.insert(i) }
                }
            }

            GameTopBar(title: "Deep Sea Treasure Hunt", count: "Treasure: \(collected.count) / 16", time: formatTime(missionTimeRemaining), backAction: { screen = "missionChoice" })

            VStack {
                Spacer()
                HStack(spacing: 8) {
                    Button { screen = "reefBuilder" } label: {
                        Text("Reef").mainButton(color: .purple)
                    }
                    Button { screen = "missionTimerOnly" } label: {
                        Text("Timer").mainButton(color: .green)
                    }
                }
                .padding(.horizontal, 22)

                Button { finishSession() } label: {
                    Text("Finish Session").mainButton(color: .green)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 28)
            }

            if showHowToPlay {
                HowToPlayPopup(title: "How to Play", message: "Tap treasure chests before they drift away. Your mission timer keeps running even if you switch activities.", buttonText: "Start Hunt", closeAction: { showHowToPlay = false })
            }
        }
        .ignoresSafeArea()
        .onAppear {
            timerRunning = true
            treasureMove = true
        }
    }

    func finishSession() {
        timerRunning = false
        screen = "missionComplete"
    }

    func formatTime(_ seconds: Int) -> String {
        "\(seconds / 60):\(String(format: "%02d", seconds % 60))"
    }
}

struct ReefBuilderScreen: View {
    @Binding var screen: String
    @Binding var currentSession: Int
    @Binding var currentPlanetIndex: Int
    @Binding var missionTimeRemaining: Int
    @Binding var timerRunning: Bool

    @State private var coralMove = false
    @State private var placed: Set<Int> = []

    var body: some View {
        ZStack {
            OceanusPrimeScene()

            ForEach(0..<18, id: \.self) { i in
                if !placed.contains(i) {
                    CoralPiece(color: [.pink, .orange, .purple, .cyan, .yellow, .green][i % 6])
                        .frame(width: 45, height: 55)
                        .position(
                            x: CGFloat(35 + (i % 4) * 90),
                            y: coralMove ? CGFloat(165 + (i / 4) * 100) : CGFloat(690 - (i / 4) * 80)
                        )
                        .animation(.easeInOut(duration: Double(2.2 + Double(i % 5) * 0.3)).repeatForever(autoreverses: true), value: coralMove)
                        .onTapGesture { placed.insert(i) }
                }
            }

            GameTopBar(title: "Reef Builder", count: "Coral Built: \(placed.count) / 18", time: formatTime(missionTimeRemaining), backAction: { screen = "missionChoice" })

            VStack {
                Spacer()
                HStack(spacing: 8) {
                    Button { screen = "treasureHunt" } label: {
                        Text("Treasure").mainButton(color: .blue)
                    }
                    Button { screen = "missionTimerOnly" } label: {
                        Text("Timer").mainButton(color: .green)
                    }
                }
                .padding(.horizontal, 22)

                Button { finishSession() } label: {
                    Text("Finish Session").mainButton(color: .green)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 28)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            timerRunning = true
            coralMove = true
        }
    }

    func finishSession() {
        timerRunning = false
        screen = "missionComplete"
    }

    func formatTime(_ seconds: Int) -> String {
        "\(seconds / 60):\(String(format: "%02d", seconds % 60))"
    }
}

struct MissionTimerOnlyScreen: View {
    @Binding var screen: String
    @Binding var currentSession: Int
    @Binding var currentPlanetIndex: Int
    @Binding var missionTimeRemaining: Int
    @Binding var timerRunning: Bool

    var body: some View {
        ZStack {
            currentPlanetIndex == 1 ? AnyView(OceanusPrimeScene()) : AnyView(CrystalLagoonScene())

            VStack {
                HStack {
                    Button { screen = "missionChoice" } label: {
                        Text("← Back")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    Spacer()
                    Text(formatTime(missionTimeRemaining))
                        .font(.headline)
                        .foregroundColor(.cyan)
                }
                .padding(.horizontal, 22)
                .padding(.top, 75)

                Spacer()

                VStack(spacing: 14) {
                    Text("Mission Time Remaining")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text(formatTime(missionTimeRemaining))
                        .font(.system(size: 76, weight: .black, design: .rounded))
                        .foregroundColor(.cyan)
                        .shadow(color: .cyan.opacity(0.7), radius: 18)

                    Text("Relax on \(planetName(currentPlanetIndex)) while your mission continues.")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                }
                .padding(24)
                .background(.black.opacity(0.42))
                .cornerRadius(28)
                .padding(.horizontal, 24)

                Spacer()

                HStack(spacing: 8) {
                    if currentPlanetIndex == 1 {
                        Button { screen = "treasureHunt" } label: {
                            Text("Treasure").mainButton(color: .blue)
                        }
                        Button { screen = "reefBuilder" } label: {
                            Text("Reef").mainButton(color: .purple)
                        }
                    } else {
                        Button { screen = "alienFishing" } label: {
                            Text("Fishing").mainButton(color: .blue)
                        }
                        Button { screen = "crystalCollector" } label: {
                            Text("Snake").mainButton(color: .purple)
                        }
                    }
                }
                .padding(.horizontal, 22)

                Button { finishSession() } label: {
                    Text("Finish Session").mainButton(color: .green)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            timerRunning = true
        }
    }

    func finishSession() {
        timerRunning = false
        screen = "missionComplete"
    }

    func formatTime(_ seconds: Int) -> String {
        "\(seconds / 60):\(String(format: "%02d", seconds % 60))"
    }
}


// MARK: - Landing Congrats

struct LandingCongratsScreen: View {
    @Binding var screen: String

    @State private var burst = false

    var body: some View {
        ZStack {
            CrystalLagoonScene()
                .ignoresSafeArea()

            FireworksView(burst: burst)

            VStack(spacing: 18) {
                Spacer()

                Text("🎉 Congrats! 🎉")
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .yellow.opacity(0.9), radius: 12)
                    .multilineTextAlignment(.center)

                Text("You have completed your first landing alignment.")
                    .font(.title2.bold())
                    .foregroundColor(.yellow)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
                    .shadow(radius: 8)

                Button {
                    screen = "missionChoice"
                } label: {
                    Text("Continue Mission").mainButton(color: .green)
                }
                .padding(.horizontal, 28)
                .padding(.top, 12)

                Spacer()
            }
            .padding(.top, 75)
        }
        .onAppear {
            burst = true
        }
    }
}



// MARK: - Second Landing Congrats

struct SecondLandingCongratsScreen: View {
    @Binding var screen: String

    @State private var burst = false

    var body: some View {
        ZStack {
            OceanusPrimeScene()
                .ignoresSafeArea()

            FireworksView(burst: burst)

            VStack(spacing: 18) {
                Spacer()

                Text("🎉 Congrats! 🎉")
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .yellow.opacity(0.9), radius: 12)
                    .multilineTextAlignment(.center)

                Text("You have completed your second landing alignment.")
                    .font(.title2.bold())
                    .foregroundColor(.yellow)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
                    .shadow(radius: 8)

                Button {
                    screen = "missionChoice"
                } label: {
                    Text("Continue Mission").mainButton(color: .green)
                }
                .padding(.horizontal, 28)
                .padding(.top, 12)

                Spacer()
            }
            .padding(.top, 75)
        }
        .onAppear {
            burst = true
        }
    }
}


// MARK: - Mission Complete Celebration

struct MissionCompleteScreen: View {
    @Binding var screen: String
    @Binding var currentPlanetIndex: Int

    @State private var animate = false
    @State private var burst = false

    var body: some View {
        ZStack {
            currentPlanetIndex == 1 ? AnyView(OceanusPrimeScene()) : AnyView(CrystalLagoonScene())

            ConfettiView(animate: animate)
            FireworksView(burst: burst)

            VStack(spacing: 16) {
                Spacer()

                Text("Mission Complete")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .cyan, radius: 14)
                    .multilineTextAlignment(.center)

                Text(currentPlanetIndex < 2 ? "Next planet unlocked" : "Galaxy training complete")
                    .font(.title3.bold())
                    .foregroundColor(.yellow)
                    .shadow(radius: 8)

                Text("Great job holding your mission target.")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Spacer()

                Button {
                    if currentPlanetIndex < 2 {
                        screen = "planetTransit"
                    } else {
                        screen = "patientDashboard"
                    }
                } label: {
                    Text(currentPlanetIndex < 2 ? "Launch Next Mission" : "Return to Dashboard")
                        .mainButton(color: .cyan)
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 38)
            }
            .padding(.top, 80)
        }
        .ignoresSafeArea()
        .onAppear {
            animate = true
            burst = true
        }
    }
}

struct ConfettiView: View {
    let animate: Bool
    let colors: [Color] = [.red, .yellow, .cyan, .purple, .orange, .green, .pink]

    var body: some View {
        ZStack {
            ForEach(0..<70, id: \.self) { i in
                Rectangle()
                    .fill(colors[i % colors.count])
                    .frame(width: CGFloat(6 + i % 5), height: CGFloat(10 + i % 7))
                    .rotationEffect(.degrees(animate ? Double((i * 37) % 360) : 0))
                    .position(
                        x: CGFloat(12 + (i * 47) % 370),
                        y: animate ? CGFloat(820 + (i % 8) * 20) : CGFloat(-60 - (i % 9) * 30)
                    )
                    .animation(.linear(duration: Double(2.4 + Double(i % 7) * 0.28)).repeatForever(autoreverses: false), value: animate)
            }
        }
    }
}

struct FireworksView: View {
    let burst: Bool
    let colors: [Color] = [.yellow, .cyan, .pink, .purple, .orange, .green]

    var body: some View {
        ZStack {
            FireworkBurst(centerX: 90, centerY: 190, burst: burst, colors: colors)
            FireworkBurst(centerX: 310, centerY: 240, burst: burst, colors: colors.reversed())
            FireworkBurst(centerX: 200, centerY: 130, burst: burst, colors: colors)
        }
    }
}

struct FireworkBurst: View {
    let centerX: CGFloat
    let centerY: CGFloat
    let burst: Bool
    let colors: [Color]

    var body: some View {
        ZStack {
            ForEach(0..<18, id: \.self) { i in
                Circle()
                    .fill(colors[i % colors.count])
                    .frame(width: 8, height: 8)
                    .position(
                        x: centerX + (burst ? cos(CGFloat(i) * .pi / 9) * CGFloat(55 + (i % 3) * 18) : 0),
                        y: centerY + (burst ? sin(CGFloat(i) * .pi / 9) * CGFloat(55 + (i % 3) * 18) : 0)
                    )
                    .opacity(burst ? 0.95 : 0.2)
                    .animation(.easeOut(duration: 1.0).repeatForever(autoreverses: false), value: burst)
            }
        }
    }
}

// MARK: - Reusable UI

struct GameTopBar: View {
    let title: String
    let count: String
    let time: String
    let backAction: () -> Void

    var body: some View {
        VStack {
            HStack {
                Button { backAction() } label: {
                    Text("← Back")
                        .foregroundColor(.white)
                        .font(.headline)
                }
                Spacer()
                Text(time)
                    .font(.headline)
                    .foregroundColor(.cyan)
            }
            .padding(.horizontal, 22)
            .padding(.top, 75)

            Text(title)
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .shadow(radius: 5)

            Text(count)
                .font(.headline)
                .foregroundColor(.yellow)

            Spacer()
        }
    }
}

struct HowToPlayPopup: View {
    let title: String
    let message: String
    let buttonText: String
    let closeAction: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.system(size: 26, weight: .black, design: .rounded))
                .foregroundColor(.white)

            Text(message)
                .font(.headline)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)

            Button { closeAction() } label: {
                Text(buttonText).mainButton(color: .blue)
            }
        }
        .padding(24)
        .background(.black.opacity(0.84))
        .cornerRadius(28)
        .padding(.horizontal, 28)
    }
}

// MARK: - Game Scenes

struct TinyFishingGameScene: View {
    let avatar: AvatarProfile
    @Binding var hookX: CGFloat
    @Binding var hookY: CGFloat
    let isFishingActive: Bool
    @Binding var caughtFish: Set<Int>
    @Binding var totalScore: Int
    let fishingLevel: Int
    let fishGoal: Int

    let fishColors: [Color] = [.purple, .green, .orange, .cyan, .pink, .yellow, .blue, .red]

    var body: some View {
        ZStack {
            // Small shore platform where the astronaut stands.
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(red: 0.92, green: 0.76, blue: 0.48).opacity(0.96))
                .frame(width: 180, height: 70)
                .position(x: 92, y: 378)

            AstronautFishingDock(avatar: avatar)
                .frame(width: 150, height: 230)
                .position(x: 88, y: 320)

            // Fishing rod: starts exactly at the extended glove.
            Path { path in
                path.move(to: CGPoint(x: 145, y: 330))
                path.addLine(to: CGPoint(x: 255, y: 105))
            }
            .stroke(Color.brown, style: StrokeStyle(lineWidth: 8, lineCap: .round))

            Circle()
                .fill(avatar.gloveBootColor)
                .frame(width: 22, height: 22)
                .position(x: 145, y: 330)

            // Fishing line from rod tip to moving hook.
            Path { path in
                path.move(to: CGPoint(x: 255, y: 105))
                path.addLine(to: CGPoint(x: hookX, y: hookY))
            }
            .stroke(Color.white.opacity(0.86), style: StrokeStyle(lineWidth: 2, lineCap: .round))

            TinyHook()
                .frame(width: 28, height: 36)
                .position(x: hookX, y: hookY)
                .shadow(color: .white.opacity(0.8), radius: isFishingActive ? 8 : 2)

            VStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { i in
                    HStack {
                        Text("\(i * 10)m")
                            .font(.caption2.bold())
                            .foregroundColor(.white.opacity(0.75))
                        Spacer()
                    }
                    .frame(height: 72)
                }
            }
            .padding(.leading, 10)
            .position(x: 38, y: 430)

            ForEach(0..<fishGoal, id: \.self) { i in
                TinyFishingFish(
                    id: i,
                    color: fishColors[i % fishColors.count],
                    baseY: CGFloat(420 + (i % 5) * 52 + min(fishingLevel * 6, 40)),
                    leftToRight: i % 2 == 0,
                    isFishingActive: isFishingActive,
                    hookX: hookX,
                    hookY: hookY,
                    caughtFish: $caughtFish,
                    totalScore: $totalScore
                )
            }
        }
    }
}


struct TinyFishingFish: View {
    let id: Int
    let color: Color
    let baseY: CGFloat
    let leftToRight: Bool
    let isFishingActive: Bool
    let hookX: CGFloat
    let hookY: CGFloat
    @Binding var caughtFish: Set<Int>
    @Binding var totalScore: Int

    var body: some View {
        TimelineView(.animation) { timeline in
            let cycleDuration = 5.5 + Double(id % 4)
            let elapsed = timeline.date.timeIntervalSinceReferenceDate + Double(id) * 0.35
            let progress = (elapsed.truncatingRemainder(dividingBy: cycleDuration)) / cycleDuration
            let startX: CGFloat = leftToRight ? 25.0 : 365.0
            let endX: CGFloat = leftToRight ? 365.0 : 25.0
            let fishX = startX + (endX - startX) * CGFloat(progress)
            let fishY = baseY + sin(CGFloat(elapsed) * 2.2) * 16
            let isNearHook = abs(hookX - fishX) < 42 && abs(hookY - fishY) < 34

            Group {
                if !caughtFish.contains(id) {
                    BetterFish(color: color, facingRight: leftToRight)
                        .frame(width: CGFloat(54 + (id % 4) * 12), height: CGFloat(32 + (id % 3) * 6))
                        .position(x: fishX, y: fishY)
                        .onChange(of: isNearHook) { _, newValue in
                            collectFishIfNeeded(newValue)
                        }
                        .onAppear {
                            collectFishIfNeeded(isNearHook)
                        }
                }
            }
        }
    }

    func collectFishIfNeeded(_ shouldCollect: Bool) {
        if shouldCollect && isFishingActive && !caughtFish.contains(id) {
            DispatchQueue.main.async {
                if !caughtFish.contains(id) {
                    caughtFish.insert(id)
                    totalScore += 10 + id * 2
                }
            }
        }
    }
}


struct BetterFish: View {
    let color: Color
    let facingRight: Bool

    var body: some View {
        ZStack {
            // smoother alien fish body
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [color.opacity(0.98), color.opacity(0.72)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Capsule()
                        .stroke(.white.opacity(0.28), lineWidth: 2)
                )

            // tail
            Triangle()
                .fill(color.opacity(0.88))
                .frame(width: 24, height: 28)
                .rotationEffect(.degrees(facingRight ? -90 : 90))
                .offset(x: facingRight ? -34 : 34)

            // top fin
            Triangle()
                .fill(.white.opacity(0.28))
                .frame(width: 18, height: 14)
                .rotationEffect(.degrees(180))
                .offset(x: facingRight ? -5 : 5, y: -18)

            // eye
            Circle()
                .fill(.white)
                .frame(width: 9, height: 9)
                .offset(x: facingRight ? 22 : -22, y: -6)

            Circle()
                .fill(.black)
                .frame(width: 4, height: 4)
                .offset(x: facingRight ? 24 : -24, y: -6)

            // cute cheek bubble
            Circle()
                .fill(.white.opacity(0.42))
                .frame(width: 11, height: 11)
                .offset(x: facingRight ? 8 : -8, y: 9)

            // shine stripe
            Capsule()
                .fill(.white.opacity(0.45))
                .frame(width: 24, height: 5)
                .rotationEffect(.degrees(-12))
                .offset(x: facingRight ? -6 : 6, y: -11)
        }
    }
}

struct TinyHook: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.white.opacity(0.9))
                .frame(width: 3, height: 26)
                .offset(y: -8)

            Circle()
                .stroke(Color.yellow, lineWidth: 4)
                .frame(width: 22, height: 22)
                .offset(y: 8)

            Rectangle()
                .fill(.cyan)
                .frame(width: 16, height: 10)
                .offset(y: -2)
        }
    }
}

struct AstronautFishingDock: View {
    let avatar: AvatarProfile

    var body: some View {
        ZStack {
            // The astronaut already has one raised arm in AstronautFisherFull.
            // Do not add a second rod-holding hand here.
            AstronautFisherFull(avatar: avatar)
        }
    }
}

struct TinyFishingLagoonScene: View {
    @State private var waves = false
    @State private var ships = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.58, blue: 0.92),
                    Color(red: 0.05, green: 0.82, blue: 0.92),
                    Color(red: 0.02, green: 0.42, blue: 0.82),
                    Color(red: 0.00, green: 0.16, blue: 0.44)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            ForEach(0..<34, id: \.self) { _ in
                Circle()
                    .fill(.white.opacity(Double.random(in: 0.25...0.75)))
                    .frame(width: CGFloat.random(in: 1...3))
                    .position(x: CGFloat.random(in: 0...390), y: CGFloat.random(in: 20...260))
            }

            Circle()
                .fill(.yellow.opacity(0.92))
                .frame(width: 96, height: 96)
                .position(x: 315, y: 105)
                .shadow(color: .yellow.opacity(0.55), radius: 25)

            MiniSpaceship()
                .frame(width: 54, height: 24)
                .position(x: ships ? 60 : 320, y: 150)
                .animation(.easeInOut(duration: 3.8).repeatForever(autoreverses: true), value: ships)

            Ellipse()
                .fill(.cyan.opacity(0.38))
                .frame(width: 560, height: 160)
                .position(x: waves ? 230 : 160, y: 390)
                .animation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true), value: waves)

            Ellipse()
                .fill(.blue.opacity(0.34))
                .frame(width: 600, height: 190)
                .position(x: waves ? 160 : 245, y: 485)
                .animation(.easeInOut(duration: 2.9).repeatForever(autoreverses: true), value: waves)

            Ellipse()
                .fill(.blue.opacity(0.42))
                .frame(width: 620, height: 220)
                .position(x: waves ? 245 : 155, y: 625)
                .animation(.easeInOut(duration: 3.1).repeatForever(autoreverses: true), value: waves)
        }
        .onAppear {
            waves = true
            ships = true
        }
    }
}

struct FishingLagoonScene: View {
    @State private var waves = false
    @State private var ships = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.25, blue: 0.78),
                    Color(red: 0.08, green: 0.65, blue: 0.95),
                    Color(red: 0.42, green: 0.95, blue: 0.85),
                    Color(red: 0.96, green: 0.80, blue: 0.48)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            ForEach(0..<34, id: \.self) { _ in
                Circle()
                    .fill(.white.opacity(Double.random(in: 0.35...0.9)))
                    .frame(width: CGFloat.random(in: 1...3))
                    .position(x: CGFloat.random(in: 0...390), y: CGFloat.random(in: 20...250))
            }

            Circle()
                .fill(.yellow.opacity(0.92))
                .frame(width: 105, height: 105)
                .position(x: 320, y: 115)
                .shadow(color: .yellow.opacity(0.65), radius: 35)

            MiniSpaceship()
                .frame(width: 54, height: 24)
                .position(x: ships ? 60 : 320, y: 155)
                .animation(.easeInOut(duration: 3.2).repeatForever(autoreverses: true), value: ships)

            MiniSpaceship()
                .frame(width: 46, height: 20)
                .position(x: ships ? 280 : 70, y: 205)
                .animation(.easeInOut(duration: 3.8).repeatForever(autoreverses: true), value: ships)

            Ellipse()
                .fill(.cyan.opacity(0.72))
                .frame(width: 540, height: 210)
                .position(x: waves ? 235 : 160, y: 510)
                .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: waves)

            Ellipse()
                .fill(.blue.opacity(0.50))
                .frame(width: 540, height: 140)
                .position(x: waves ? 145 : 255, y: 585)
                .animation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true), value: waves)
        }
        .onAppear {
            waves = true
            ships = true
        }
    }
}

struct CrystalCollectorScene: View {
    @State private var glow = false
    @State private var ships = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.18, blue: 0.55),
                    Color(red: 0.12, green: 0.48, blue: 0.85),
                    Color(red: 0.33, green: 0.85, blue: 0.92),
                    Color(red: 0.82, green: 0.72, blue: 0.95)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            ForEach(0..<42, id: \.self) { _ in
                Circle()
                    .fill(.white.opacity(Double.random(in: 0.35...0.9)))
                    .frame(width: CGFloat.random(in: 1...3))
                    .position(x: CGFloat.random(in: 0...390), y: CGFloat.random(in: 20...720))
            }

            Circle()
                .fill(.cyan.opacity(glow ? 0.28 : 0.13))
                .frame(width: 330, height: 330)
                .blur(radius: 60)
                .position(x: 195, y: 420)
                .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: glow)

            MiniSpaceship()
                .frame(width: 54, height: 24)
                .position(x: ships ? 70 : 315, y: 130)
                .animation(.easeInOut(duration: 3.4).repeatForever(autoreverses: true), value: ships)
        }
        .onAppear {
            glow = true
            ships = true
        }
    }
}

// MARK: - Planet Environments

struct CrystalLagoonScene: View {
    @State private var waves = false
    @State private var crystals = false
    @State private var jelly = false
    @State private var fish = false
    @State private var ships = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.25, blue: 0.78),
                    Color(red: 0.08, green: 0.65, blue: 0.95),
                    Color(red: 0.42, green: 0.95, blue: 0.85),
                    Color(red: 0.96, green: 0.80, blue: 0.48)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            ForEach(0..<38, id: \.self) { _ in
                Circle()
                    .fill(.white.opacity(Double.random(in: 0.35...0.9)))
                    .frame(width: CGFloat.random(in: 1...3))
                    .position(x: CGFloat.random(in: 0...390), y: CGFloat.random(in: 20...250))
            }

            Circle()
                .fill(.yellow.opacity(0.92))
                .frame(width: 105, height: 105)
                .position(x: 320, y: 115)
                .shadow(color: .yellow.opacity(0.65), radius: 35)

            MiniSpaceship()
                .frame(width: 54, height: 24)
                .position(x: ships ? 60 : 320, y: 155)
                .animation(.easeInOut(duration: 3.2).repeatForever(autoreverses: true), value: ships)

            MiniSpaceship()
                .frame(width: 46, height: 20)
                .position(x: ships ? 280 : 70, y: 205)
                .animation(.easeInOut(duration: 3.8).repeatForever(autoreverses: true), value: ships)

            Circle()
                .fill(.purple.opacity(0.22))
                .frame(width: 260, height: 260)
                .blur(radius: 45)
                .position(x: 90, y: 330)

            Circle()
                .fill(.cyan.opacity(0.25))
                .frame(width: 300, height: 300)
                .blur(radius: 55)
                .position(x: 310, y: 390)

            Ellipse()
                .fill(.cyan.opacity(0.72))
                .frame(width: 540, height: 210)
                .position(x: waves ? 235 : 160, y: 510)
                .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: waves)

            Ellipse()
                .fill(.blue.opacity(0.50))
                .frame(width: 540, height: 140)
                .position(x: waves ? 145 : 255, y: 585)
                .animation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true), value: waves)

            ForEach(0..<10, id: \.self) { i in
                Diamond()
                    .fill([Color.cyan, .purple, .pink, .blue][i % 4].opacity(0.85))
                    .frame(width: crystals ? 24 : 17, height: crystals ? 24 : 17)
                    .position(x: CGFloat(35 + (i % 5) * 75), y: CGFloat(610 + (i / 5) * 45))
                    .shadow(color: .cyan.opacity(0.8), radius: 10)
                    .animation(.easeInOut(duration: Double.random(in: 0.7...1.3)).repeatForever(autoreverses: true), value: crystals)
            }

            ForEach(0..<4, id: \.self) { i in
                Jellyfish(color: [.purple, .cyan, .pink, .blue][i])
                    .frame(width: 44, height: 55)
                    .offset(x: CGFloat(-140 + i * 95), y: jelly ? CGFloat(280 + i * 18) : CGFloat(325 + i * 12))
                    .animation(.easeInOut(duration: Double(1.7 + Double(i) * 0.35)).repeatForever(autoreverses: true), value: jelly)
            }

            ForEach(0..<5, id: \.self) { i in
                AlienFish(color: [.orange, .green, .purple, .cyan, .pink][i])
                    .frame(width: 48, height: 25)
                    .offset(x: fish ? CGFloat(-190 + i * 85) : CGFloat(190 - i * 75), y: CGFloat(415 + i * 25))
                    .animation(.linear(duration: Double(2.6 + Double(i) * 0.4)).repeatForever(autoreverses: true), value: fish)
            }
        }
        .onAppear {
            waves = true
            crystals = true
            jelly = true
            fish = true
            ships = true
        }
    }
}

struct OceanusPrimeScene: View {
    @State private var bubbles = false
    @State private var fish = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.01, green: 0.06, blue: 0.20),
                    Color(red: 0.02, green: 0.22, blue: 0.48),
                    Color(red: 0.03, green: 0.50, blue: 0.68),
                    Color(red: 0.01, green: 0.13, blue: 0.24)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            ForEach(0..<55, id: \.self) { i in
                Circle()
                    .fill(.cyan.opacity(0.45))
                    .frame(width: CGFloat(3 + i % 5), height: CGFloat(3 + i % 5))
                    .position(x: CGFloat(20 + (i * 37) % 350), y: bubbles ? CGFloat(60 + (i * 43) % 680) : CGFloat(750 - (i * 39) % 650))
                    .animation(.easeInOut(duration: Double(2.0 + Double(i % 7) * 0.4)).repeatForever(autoreverses: true), value: bubbles)
            }

            ForEach(0..<7, id: \.self) { i in
                AlienFish(color: [.cyan, .blue, .green, .purple, .orange, .pink, .yellow][i])
                    .frame(width: 60, height: 32)
                    .offset(x: fish ? CGFloat(-200 + i * 75) : CGFloat(210 - i * 65), y: CGFloat(230 + i * 55))
                    .animation(.easeInOut(duration: Double(4.0 + Double(i) * 0.35)).repeatForever(autoreverses: true), value: fish)
            }

            ForEach(0..<7, id: \.self) { i in
                CoralPiece(color: [.pink, .orange, .purple, .cyan, .yellow, .green, .red][i])
                    .frame(width: 55, height: 95)
                    .position(x: CGFloat(30 + i * 55), y: CGFloat(695 - (i % 2) * 20))
            }

            Text("Oceanus Prime")
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .position(x: 195, y: 80)

            Text("Coral City Reef")
                .font(.headline)
                .foregroundColor(.cyan)
                .position(x: 195, y: 118)
        }
        .onAppear {
            bubbles = true
            fish = true
        }
    }
}

struct NebulaRidgeScene: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.black, .purple, .blue, .black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            ForEach(0..<80, id: \.self) { _ in
                Circle()
                    .fill(.white.opacity(Double.random(in: 0.3...0.9)))
                    .frame(width: CGFloat.random(in: 1...4))
                    .position(x: CGFloat.random(in: 0...390), y: CGFloat.random(in: 0...800))
            }

            Text("Nebula Ridge")
                .font(.system(size: 34, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .position(x: 195, y: 95)
        }
    }
}

struct EarthSkyScene: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.02, green: 0.06, blue: 0.15),
                    Color(red: 0.04, green: 0.15, blue: 0.25),
                    .black
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            ForEach(0..<65, id: \.self) { _ in
                Circle()
                    .fill(.white.opacity(Double.random(in: 0.4...0.95)))
                    .frame(width: CGFloat.random(in: 1...3))
                    .position(x: CGFloat.random(in: 0...390), y: CGFloat.random(in: 0...420))
            }

            Circle()
                .fill(.blue.opacity(0.35))
                .frame(width: 270, height: 270)
                .position(x: 315, y: 80)

        }
    }
}

struct SpaceFlightScene: View {
    let moveStars: Bool

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.black,
                    Color(red: 0.02, green: 0.02, blue: 0.18),
                    Color(red: 0.08, green: 0.00, blue: 0.20)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // Small stars
            ForEach(0..<85, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(index % 4 == 0 ? 0.95 : 0.55))
                    .frame(
                        width: CGFloat.random(in: 1.5...4.5),
                        height: CGFloat.random(in: 1.5...4.5)
                    )
                    .position(
                        x: CGFloat.random(in: 0...390),
                        y: moveStars ? CGFloat.random(in: 760...1180) : CGFloat.random(in: -120...760)
                    )
                    .animation(
                        .linear(duration: Double.random(in: 2.8...5.8))
                        .repeatForever(autoreverses: false),
                        value: moveStars
                    )
            }

            // Distant planets
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.purple, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 95, height: 95)
                .position(x: 315, y: 155)
                .shadow(color: .purple.opacity(0.65), radius: 20)

            Circle()
                .fill(
                    LinearGradient(
                        colors: [.orange, .yellow],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 58, height: 58)
                .position(x: 72, y: 310)
                .shadow(color: .orange.opacity(0.55), radius: 16)

            Circle()
                .fill(
                    LinearGradient(
                        colors: [.cyan, .mint],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 42, height: 42)
                .position(x: 330, y: 520)
                .shadow(color: .cyan.opacity(0.55), radius: 14)

            // Comet streaks
            ForEach(0..<6, id: \.self) { index in
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.0), .cyan.opacity(0.85)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 95, height: 3)
                    .rotationEffect(.degrees(-28))
                    .offset(
                        x: moveStars ? 280 : -260,
                        y: CGFloat(-260 + index * 145)
                    )
                    .animation(
                        .linear(duration: Double(2.8 + Double(index) * 0.35))
                        .repeatForever(autoreverses: false),
                        value: moveStars
                    )
            }
        }
    }
}

// MARK: - Creatures / Objects

struct MiniSpaceship: View {
    var body: some View {
        ZStack {
            Capsule().fill(.white.opacity(0.85))
            Ellipse().fill(.cyan).frame(width: 24, height: 12).offset(y: -5)
            Circle().fill(.yellow).frame(width: 4, height: 4).offset(x: -14, y: 5)
            Circle().fill(.yellow).frame(width: 4, height: 4).offset(x: 14, y: 5)
        }
    }
}

struct AstronautFisherFull: View {
    let avatar: AvatarProfile

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(avatar.suitBaseColor)
                .frame(width: 68, height: 105)
                .offset(y: 38)

            RoundedRectangle(cornerRadius: 8)
                .fill(avatar.suitStripeColor)
                .frame(width: 9, height: 80)
                .offset(x: -28, y: 40)

            Circle()
                .fill(avatar.suitBaseColor)
                .frame(width: 82, height: 82)
                .offset(y: -48)

            Circle()
                .stroke(avatar.suitStripeColor, lineWidth: 5)
                .frame(width: 82, height: 82)
                .offset(y: -48)

            RoundedRectangle(cornerRadius: 18)
                .fill(.black.opacity(0.82))
                .frame(width: 50, height: 28)
                .offset(y: -48)

            Circle().fill(avatar.eyeColor).frame(width: 7, height: 7).offset(x: -12, y: -48)
            Circle().fill(avatar.eyeColor).frame(width: 7, height: 7).offset(x: 12, y: -48)

            RoundedRectangle(cornerRadius: 10)
                .fill(avatar.suitBaseColor)
                .frame(width: 20, height: 70)
                .rotationEffect(.degrees(18))
                .offset(x: -48, y: 38)

            RoundedRectangle(cornerRadius: 10)
                .fill(avatar.suitBaseColor)
                .frame(width: 20, height: 78)
                .rotationEffect(.degrees(-42))
                .offset(x: 48, y: 15)

            RoundedRectangle(cornerRadius: 8)
                .fill(avatar.suitBaseColor)
                .frame(width: 25, height: 70)
                .offset(x: -20, y: 110)

            RoundedRectangle(cornerRadius: 8)
                .fill(avatar.suitBaseColor)
                .frame(width: 25, height: 70)
                .offset(x: 20, y: 110)

            RoundedRectangle(cornerRadius: 8)
                .fill(avatar.gloveBootColor)
                .frame(width: 35, height: 18)
                .offset(x: -20, y: 150)

            RoundedRectangle(cornerRadius: 8)
                .fill(avatar.gloveBootColor)
                .frame(width: 35, height: 18)
                .offset(x: 20, y: 150)
        }
    }
}

struct WeirdAlienFish: View {
    let color: Color
    let size: CGFloat

    var body: some View {
        ZStack {
            Ellipse().fill(color.opacity(0.9)).scaleEffect(x: size, y: size * 0.75)
            Circle().fill(color.opacity(0.75)).frame(width: 22, height: 22).offset(x: -24)
            Triangle().fill(color.opacity(0.9)).frame(width: 20, height: 20).rotationEffect(.degrees(90)).offset(x: -38)
            Circle().fill(.white).frame(width: 7, height: 7).offset(x: 20, y: -4)
            Circle().fill(.black).frame(width: 3, height: 3).offset(x: 21, y: -4)
            Circle().fill(.white.opacity(0.55)).frame(width: 8, height: 8).offset(x: -2, y: 10)
        }
    }
}

struct SwimmingAlien: View {
    var body: some View {
        ZStack {
            Capsule().fill(.green.opacity(0.9))
            Circle().fill(.purple.opacity(0.9)).frame(width: 22, height: 22).offset(x: 25, y: -5)
            Circle().fill(.white).frame(width: 6, height: 6).offset(x: 29, y: -8)
            Circle().fill(.black).frame(width: 3, height: 3).offset(x: 30, y: -8)
        }
    }
}

struct AlienFish: View {
    let color: Color

    var body: some View {
        ZStack {
            Ellipse().fill(color.opacity(0.9))
            Triangle().fill(color.opacity(0.9)).frame(width: 18, height: 18).rotationEffect(.degrees(90)).offset(x: -22)
            Circle().fill(.white).frame(width: 5, height: 5).offset(x: 12, y: -3)
            Circle().fill(.black).frame(width: 2.5, height: 2.5).offset(x: 13, y: -3)
        }
    }
}

struct Jellyfish: View {
    let color: Color

    var body: some View {
        VStack(spacing: 0) {
            SemiCircle().fill(color.opacity(0.75)).frame(width: 38, height: 26)
            HStack(spacing: 4) {
                ForEach(0..<4, id: \.self) { _ in
                    Capsule().fill(color.opacity(0.7)).frame(width: 4, height: 18)
                }
            }
        }
    }
}

struct TreasureChest: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(.brown)
                .frame(width: 48, height: 30)
            Rectangle()
                .fill(.yellow)
                .frame(width: 6, height: 30)
            Circle()
                .fill(.yellow)
                .frame(width: 8, height: 8)
                .offset(y: 3)
        }
    }
}

struct CoralPiece: View {
    let color: Color

    var body: some View {
        ZStack {
            Capsule().fill(color.opacity(0.9)).frame(width: 10, height: 70)
            Capsule().fill(color.opacity(0.85)).frame(width: 8, height: 45).rotationEffect(.degrees(35)).offset(x: 15, y: -10)
            Capsule().fill(color.opacity(0.85)).frame(width: 8, height: 45).rotationEffect(.degrees(-35)).offset(x: -15, y: 0)
            Circle().fill(color.opacity(0.9)).frame(width: 16, height: 16).offset(y: -38)
        }
    }
}

struct AstronautView: View {
    let avatar: AvatarProfile

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28).fill(avatar.suitBaseColor).frame(width: 90, height: 118).offset(y: 50)
            RoundedRectangle(cornerRadius: 8).fill(avatar.suitStripeColor).frame(width: 12, height: 95).offset(x: -38, y: 52)
            RoundedRectangle(cornerRadius: 8).fill(avatar.suitStripeColor).frame(width: 12, height: 95).offset(x: 38, y: 52)
            Circle().fill(avatar.suitBaseColor).frame(width: 104, height: 104).offset(y: -48)
            Circle().stroke(avatar.suitStripeColor, lineWidth: 6).frame(width: 104, height: 104).offset(y: -48)
            RoundedRectangle(cornerRadius: 24).fill(avatar.skinColor).frame(width: 70, height: 42).offset(y: -48)
            RoundedRectangle(cornerRadius: 24).fill(LinearGradient(colors: [avatar.visorColor.opacity(0.55), .black.opacity(0.78)], startPoint: .topLeading, endPoint: .bottomTrailing)).frame(width: 70, height: 42).offset(y: -48)
            Circle().fill(avatar.eyeColor).frame(width: 8, height: 8).offset(x: -16, y: -48)
            Circle().fill(avatar.eyeColor).frame(width: 8, height: 8).offset(x: 16, y: -48)
            RoundedRectangle(cornerRadius: 9).fill(avatar.chestPanelColor.opacity(0.9)).frame(width: 50, height: 32).offset(y: 32)
            Circle().fill(avatar.patchColor).frame(width: 18, height: 18).overlay(Circle().stroke(.white.opacity(0.8), lineWidth: 2)).offset(x: 30, y: 5)
            RoundedRectangle(cornerRadius: 12).fill(avatar.suitBaseColor).frame(width: 24, height: 82).rotationEffect(.degrees(12)).offset(x: -66, y: 60)
            RoundedRectangle(cornerRadius: 12).fill(avatar.suitBaseColor).frame(width: 24, height: 82).rotationEffect(.degrees(-12)).offset(x: 66, y: 60)
            Circle().fill(avatar.gloveBootColor).frame(width: 25, height: 25).offset(x: -76, y: 102)
            Circle().fill(avatar.gloveBootColor).frame(width: 25, height: 25).offset(x: 76, y: 102)
            RoundedRectangle(cornerRadius: 10).fill(avatar.suitBaseColor).frame(width: 30, height: 78).offset(x: -25, y: 125)
            RoundedRectangle(cornerRadius: 10).fill(avatar.suitBaseColor).frame(width: 30, height: 78).offset(x: 25, y: 125)
            RoundedRectangle(cornerRadius: 8).fill(avatar.gloveBootColor).frame(width: 42, height: 20).offset(x: -25, y: 170)
            RoundedRectangle(cornerRadius: 8).fill(avatar.gloveBootColor).frame(width: 42, height: 20).offset(x: 25, y: 170)
        }
    }
}

struct RocketView: View {
    let bodyColor: Color
    let noseColor: Color
    let finColor: Color
    let windowColor: Color
    var showAstronaut: Bool = false
    var skinColor: Color = Color(red: 0.74, green: 0.52, blue: 0.38)
    var eyeColor: Color = .brown

    var body: some View {
        ZStack {
            Capsule().fill(LinearGradient(colors: [bodyColor, .gray], startPoint: .top, endPoint: .bottom)).frame(width: 54, height: 125)
            Triangle().fill(noseColor).frame(width: 58, height: 46).offset(y: -76)
            Circle().fill(.black).frame(width: 30, height: 30).overlay(Circle().stroke(windowColor, lineWidth: 3)).offset(y: -28)

            if showAstronaut {
                Circle().fill(skinColor).frame(width: 16, height: 16).offset(y: -28)
                Circle().fill(eyeColor).frame(width: 3, height: 3).offset(x: -4, y: -29)
                Circle().fill(eyeColor).frame(width: 3, height: 3).offset(x: 4, y: -29)
            }

            Triangle().fill(finColor).frame(width: 35, height: 45).rotationEffect(.degrees(-35)).offset(x: -36, y: 38)
            Triangle().fill(finColor).frame(width: 35, height: 45).rotationEffect(.degrees(35)).offset(x: 36, y: 38)
            Flame().fill(LinearGradient(colors: [.yellow, .orange, .red], startPoint: .top, endPoint: .bottom)).frame(width: 32, height: 55).offset(y: 98)
        }
    }
}

// MARK: - Shapes + Styling

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct Flame: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addCurve(to: CGPoint(x: rect.midX, y: rect.maxY), control1: CGPoint(x: rect.maxX, y: rect.height * 0.35), control2: CGPoint(x: rect.maxX, y: rect.height * 0.8))
        path.addCurve(to: CGPoint(x: rect.midX, y: rect.minY), control1: CGPoint(x: rect.minX, y: rect.height * 0.8), control2: CGPoint(x: rect.minX, y: rect.height * 0.35))
        return path
    }
}

struct SemiCircle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.maxY), radius: rect.width / 2, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
        path.closeSubpath()
        return path
    }
}

struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        return path
    }
}

struct WelcomeSpaceDecorations: View {
    @State private var float = false

    var body: some View {
        ZStack {
            ForEach(0..<70, id: \.self) { i in
                Circle()
                    .fill(.white.opacity(Double(0.25 + Double(i % 5) * 0.12)))
                    .frame(width: CGFloat(2 + (i % 3)), height: CGFloat(2 + (i % 3)))
                    .position(x: CGFloat(12 + (i * 43) % 370), y: CGFloat(28 + (i * 61) % 720))
            }

            PlanetBubble(color: .purple, ringColor: .pink)
                .frame(width: 90, height: 90)
                .position(x: 326, y: 205)

            PlanetBubble(color: .cyan, ringColor: .blue)
                .frame(width: 72, height: 72)
                .position(x: 58, y: 505)

            PlanetBubble(color: .green, ringColor: .cyan)
                .frame(width: 58, height: 58)
                .position(x: 340, y: 545)

            PlanetBubble(color: .orange, ringColor: .yellow)
                .frame(width: 66, height: 66)
                .position(x: 62, y: 185)

            MiniSpaceship()
                .frame(width: 92, height: 42)
                .position(x: float ? 80 : 310, y: 120)
                .animation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true), value: float)

            MiniSpaceship()
                .frame(width: 58, height: 28)
                .rotationEffect(.degrees(-12))
                .position(x: float ? 315 : 95, y: 630)
                .animation(.easeInOut(duration: 4.8).repeatForever(autoreverses: true), value: float)

            CuteFloatingAlien(color: .green)
                .frame(width: 58, height: 58)
                .position(x: 70, y: float ? 250 : 278)
                .animation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true), value: float)

            CuteFloatingAlien(color: .purple)
                .frame(width: 50, height: 50)
                .position(x: 325, y: float ? 318 : 290)
                .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true), value: float)

            CuteFloatingAlien(color: .cyan)
                .frame(width: 46, height: 46)
                .position(x: 285, y: float ? 455 : 480)
                .animation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true), value: float)

            CuteFloatingAlien(color: .orange)
                .frame(width: 44, height: 44)
                .position(x: 115, y: float ? 650 : 620)
                .animation(.easeInOut(duration: 3.2).repeatForever(autoreverses: true), value: float)

            CuteFloatingAlien(color: .pink)
                .frame(width: 40, height: 40)
                .position(x: 315, y: float ? 92 : 112)
                .animation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true), value: float)
        }
        .allowsHitTesting(false)
        .onAppear { float = true }
    }
}

struct TravelingPlanetField: View {
    let animate: Bool

    var body: some View {
        ZStack {
            PlanetBubble(color: .purple, ringColor: .pink)
                .frame(width: 92, height: 92)
                .position(x: animate ? 60 : 25, y: 175)
                .animation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true), value: animate)

            PlanetBubble(color: .green, ringColor: .cyan)
                .frame(width: 64, height: 64)
                .position(x: animate ? 330 : 360, y: 265)
                .animation(.easeInOut(duration: 3.1).repeatForever(autoreverses: true), value: animate)

            PlanetBubble(color: .orange, ringColor: .yellow)
                .frame(width: 120, height: 120)
                .position(x: animate ? 305 : 260, y: 590)
                .animation(.easeInOut(duration: 3.6).repeatForever(autoreverses: true), value: animate)

            PlanetBubble(color: .blue, ringColor: .white)
                .frame(width: 72, height: 72)
                .position(x: animate ? 80 : 115, y: 700)
                .animation(.easeInOut(duration: 3.3).repeatForever(autoreverses: true), value: animate)
        }
        .allowsHitTesting(false)
    }
}

struct PlanetBubble: View {
    let color: Color
    let ringColor: Color

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.95), color.opacity(0.55), .black.opacity(0.18)],
                        center: .topLeading,
                        startRadius: 4,
                        endRadius: 55
                    )
                )
                .shadow(color: color.opacity(0.55), radius: 12)

            Capsule()
                .stroke(ringColor.opacity(0.65), lineWidth: 4)
                .frame(width: 92, height: 28)
                .rotationEffect(.degrees(-18))

            Circle()
                .fill(.white.opacity(0.42))
                .frame(width: 14, height: 14)
                .offset(x: -16, y: -15)
        }
    }
}

struct CuteFloatingAlien: View {
    let color: Color

    var body: some View {
        ZStack {
            Capsule()
                .fill(color.opacity(0.92))
                .overlay(Capsule().stroke(.white.opacity(0.35), lineWidth: 2))

            HStack(spacing: 14) {
                Circle().fill(.white).frame(width: 9, height: 9)
                Circle().fill(.white).frame(width: 9, height: 9)
            }
            .offset(y: -4)

            HStack(spacing: 14) {
                Circle().fill(.black).frame(width: 4, height: 4)
                Circle().fill(.black).frame(width: 4, height: 4)
            }
            .offset(y: -4)

            HStack(spacing: 12) {
                Capsule().fill(.white.opacity(0.75)).frame(width: 4, height: 16)
                Capsule().fill(.white.opacity(0.75)).frame(width: 4, height: 16)
            }
            .offset(y: 26)
        }
    }
}

struct SpaceBackground: View {
    var body: some View {
        LinearGradient(colors: [Color(red: 0.01, green: 0.02, blue: 0.08), Color(red: 0.02, green: 0.08, blue: 0.24), Color(red: 0.10, green: 0.02, blue: 0.20), .black], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
    }
}

extension Text {
    func mainButton(color: Color) -> some View {
        self.font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(color)
            .cornerRadius(15)
    }

    func miniButton() -> some View {
        self.font(.system(size: 22, weight: .bold))
            .foregroundColor(.white)
            .frame(width: 46, height: 36)
            .background(.white.opacity(0.18))
            .cornerRadius(12)
    }
}

extension View {
    func textFieldStyleCustom() -> some View {
        self.padding(.vertical, 11)
            .padding(.horizontal, 12)
            .background(.white.opacity(0.95))
            .cornerRadius(14)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
    }
}

#Preview {
    ContentView()
}




