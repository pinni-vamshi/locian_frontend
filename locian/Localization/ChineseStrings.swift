//
//  ChineseStrings.swift
//  locian
//

import Foundation
import Combine

struct ChineseStrings: AppStrings, LocalizedStrings {
    
    var ui: UIStrings {
        UIStrings(
            historyLog: "历史记录",
            startLearning: "开始学习",
            sunShort: "日",
            monShort: "一",
            tueShort: "二",
            wedShort: "三",
            thuShort: "四",
            friShort: "五",
            satShort: "六",
            settings: "设置",
            done: "完成",
            cancel: "取消",
            delete: "删除",
            edit: "编辑",
            error: "错误",
            ok: "确定",
            learnTab: "学习",
            progressTab: "进度",
            loading: "加载中...",
            noInternetConnection: "无网络连接",
            retry: "重试")
    }

    var settings: SettingsStrings {
        SettingsStrings(
            systemLanguage: "应用界面",
            notifications: "通知",
            account: "账户",
            addLanguagePair: "添加语言对",
            logout: "登出",
            nativeLanguage: "母 语",
            selectTargetLanguage: "选择目标语言",
            neonGreen: "霓虹绿",
            neonFuchsia: "霓虹紫",
            electricIndigo: "电力靛",
            graphiteBlack: "石墨黑",
            student: "学生",
            softwareEngineer: "软件工程师",
            teacher: "教师",
            doctor: "医生",
            artist: "艺术家",
            businessProfessional: "商务专业人士",
            salesOrMarketing: "销售或营销",
            traveler: "旅行者",
            homemaker: "家庭主妇/夫",
            chef: "厨师",
            police: "警察",
            bankEmployee: "银行职员",
            nurse: "护士",
            designer: "设计师",
            engineerManager: "工程经理",
            photographer: "摄影师",
            contentCreator: "内容创作者",
            entrepreneur: "企业家",
            other: "其他",
            systemConfig: "系统 // 配置",
            currentLevel: "当前级别",
            location: "位置",
            areYouSureLogout: "您确定要退出吗？",
            areYouSureDeleteAccount: "您确定要永久删除您的帐户吗？此操作无法撤消。")
    }

    var login: LoginStrings {
        LoginStrings(
            selectUserProfession: "SELECT_USER_PROFESSION",
            authenticatingUser: "AUTHENTICATING_USER...")
    }

    var onboarding: OnboardingStrings {
        OnboardingStrings(
            selectLanguageDescription: "选择您的首选语言",
            whichLanguageDoYouSpeakComfortably: "您舒适地说哪种语言?",
            chooseTheLanguageYouWantToMaster: "选择您今天想要掌握的语言")
    }

    var progress: ProgressStrings {
        ProgressStrings(
            addLanguagePairToSeeProgress: "添加语言对以查看您的进度",
            streakStatus: "连胜状态",
            chronotype: "昼夜节律型",
            activityDistribution: "活动分布 (24小时)",
            earlyBird: "早起鸟",
            earlyBirdDesc: "早晨最为活跃",
            dayWalker: "昼行者",
            dayWalkerDesc: "下午最为活跃",
            nightOwl: "夜猫子",
            nightOwlDesc: "入夜后最为活跃")
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
        case .smartNotificationExactPlace: return "如果你在%@，了解一下这个地方！"
        default: return key.rawValue
        }
    }
}
