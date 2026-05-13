//
//  JapaneseStrings.swift
//  locian
//

import Foundation
import Combine

struct JapaneseStrings: AppStrings, LocalizedStrings {
    
    var ui: UIStrings {
        UIStrings(
            historyLog: "履歴ログ",
            startLearning: "学習を開始",
            sunShort: "日",
            monShort: "月",
            tueShort: "火",
            wedShort: "水",
            thuShort: "木",
            friShort: "金",
            satShort: "土",
            settings: "設定",
            done: "完了",
            cancel: "キャンセル",
            delete: "削除",
            edit: "編集",
            error: "エラー",
            ok: "OK",
            learnTab: "学習",
            progressTab: "進捗",
            loading: "読み込み中...",
            noInternetConnection: "インターネット接続なし",
            retry: "再試行")
    }

    var settings: SettingsStrings {
        SettingsStrings(
            systemLanguage: "アプリのインターフェース",
            notifications: "通知",
            account: "アカウント",
            addLanguagePair: "言語ペアを追加",
            logout: "ログアウト",
            nativeLanguage: "母国 語",
            selectTargetLanguage: "目標言語を選択",
            neonGreen: "ネオングリーン",
            neonFuchsia: "ネオンフクシア",
            electricIndigo: "エレクトリックインディゴ",
            graphiteBlack: "グラファイトブラック",
            student: "学生",
            softwareEngineer: "ソフトウェアエンジニア",
            teacher: "教師",
            doctor: "医師",
            artist: "アーティスト",
            businessProfessional: "ビジネスプロフェッショナル",
            salesOrMarketing: "営業またはマーケティング",
            traveler: "旅行者",
            homemaker: "主婦/主夫",
            chef: "シェフ",
            police: "警察官",
            bankEmployee: "銀行員",
            nurse: "看護師",
            designer: "デザイナー",
            engineerManager: "エンジニアリングマネージャー",
            photographer: "写真家",
            contentCreator: "コンテンツクリエイター",
            entrepreneur: "起業家",
            other: "その他",
            systemConfig: "システム // 設定",
            currentLevel: "現在のレベル",
            location: "位置情報",
            areYouSureLogout: "ログアウトしてもよろしいですか？",
            areYouSureDeleteAccount: "アカウントを完全に削除してもよろしいですか？この操作は取り消せません。")
    }

    var login: LoginStrings {
        LoginStrings(
            selectUserProfession: "SELECT_USER_PROFESSION",
            authenticatingUser: "AUTHENTICATING_USER...")
    }

    var onboarding: OnboardingStrings {
        OnboardingStrings(
            selectLanguageDescription: "優先言語を選択",
            whichLanguageDoYouSpeakComfortably: "どの言語を快適に話しますか?",
            chooseTheLanguageYouWantToMaster: "今日マスターしたい言語を選んでください")
    }

    var progress: ProgressStrings {
        ProgressStrings(
            addLanguagePairToSeeProgress: "進捗を確認するには言語ペアを追加してください",
            streakStatus: "ストリークステータス",
            chronotype: "クロノタイプ",
            activityDistribution: "活動分布 (24時間)",
            earlyBird: "早起き",
            earlyBirdDesc: "朝に最も活発",
            dayWalker: "デイウォーカー",
            dayWalkerDesc: "午後に最も活発",
            nightOwl: "夜型",
            nightOwlDesc: "夜間に最も活発")
    }

    var scene: SceneStrings {
        SceneStrings(
                                                                                                                                                                                                                                                                                                                                                                                            )
    }


    func getString(_ key: String) -> String {
        return key
    }
    
                                    func getString(for key: StringKey) -> String {
        switch key {
        case .notifications: return settings.notifications
        case .account: return settings.account
        case .settings: return ui.settings
        case .done: return ui.done
        case .cancel: return ui.cancel
        case .delete: return ui.delete
        case .edit: return ui.edit
        case .learnTab: return ui.learnTab
        case .progressTab: return ui.progressTab
        case .loading: return ui.loading
        case .noInternetConnection: return ui.noInternetConnection
        case .retry: return ui.retry
        case .systemLanguage: return settings.systemLanguage
        case .logout: return settings.logout
        case .addLanguagePair: return settings.addLanguagePair
        case .historyLog: return ui.historyLog


        case .startLearningLabel: return ui.startLearning
        case .sunShort: return ui.sunShort
        case .monShort: return ui.monShort
        case .tueShort: return ui.tueShort
        case .wedShort: return ui.wedShort
        case .thuShort: return ui.thuShort
        case .friShort: return ui.friShort
        case .satShort: return ui.satShort
        case .currentLevel: return settings.currentLevel
        case .areYouSureLogout: return settings.areYouSureLogout
        case .areYouSureDeleteAccount: return settings.areYouSureDeleteAccount
        case .nativeLanguage: return settings.nativeLanguage
        case .selectTargetLanguage: return settings.selectTargetLanguage
        case .neonGreen: return settings.neonGreen
        case .neonFuchsia: return settings.neonFuchsia
        case .electricIndigo: return settings.electricIndigo
        case .graphiteBlack: return settings.graphiteBlack
        case .error: return ui.error
        case .ok: return ui.ok
        case .selectLanguageDescription: return onboarding.selectLanguageDescription
        case .whichLanguageDoYouSpeakComfortably: return onboarding.whichLanguageDoYouSpeakComfortably
        case .chooseTheLanguageYouWantToMaster: return onboarding.chooseTheLanguageYouWantToMaster
        case .authenticatingUser: return login.authenticatingUser
        case .selectUserProfession: return login.selectUserProfession
        case .student: return settings.student
        case .softwareEngineer: return settings.softwareEngineer
        case .teacher: return settings.teacher
        case .doctor: return settings.doctor
        case .artist: return settings.artist
        case .businessProfessional: return settings.businessProfessional
        case .salesOrMarketing: return settings.salesOrMarketing
        case .traveler: return settings.traveler
        case .activityDistribution: return progress.activityDistribution
        case .earlyBird: return progress.earlyBird
        case .earlyBirdDesc: return progress.earlyBirdDesc
        case .dayWalker: return progress.dayWalker
        case .dayWalkerDesc: return progress.dayWalkerDesc
        case .nightOwl: return progress.nightOwl
        case .nightOwlDesc: return progress.nightOwlDesc
        case .homemaker: return settings.homemaker
        case .chef: return settings.chef
        case .police: return settings.police
        case .bankEmployee: return settings.bankEmployee
        case .nurse: return settings.nurse
        case .designer: return settings.designer
        case .engineerManager: return settings.engineerManager
        case .photographer: return settings.photographer
        case .contentCreator: return settings.contentCreator
        case .entrepreneur: return settings.entrepreneur
        case .other: return settings.other
        case .systemConfig: return settings.systemConfig
        case .streakStatus: return progress.streakStatus
        case .addLanguagePairToSeeProgress: return progress.addLanguagePairToSeeProgress
        
        // (Onboarding string mappings removed)
        // Advanced Stats
        case .chronotype: return progress.chronotype

        // Personalization Refresh
        case .smartNotificationExactPlace: return "%@にいるなら、この場所について読んでみてください！"
        default: return key.rawValue
        }
    }
}
