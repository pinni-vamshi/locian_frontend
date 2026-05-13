//
//  KoreanStrings.swift
//  locian
//

import Foundation
import Combine

struct KoreanStrings: AppStrings, LocalizedStrings {
    
    var ui: UIStrings {
        UIStrings(
            historyLog: "기록 로그",
            startLearning: "학습 시작",
            sunShort: "일",
            monShort: "월",
            tueShort: "화",
            wedShort: "수",
            thuShort: "목",
            friShort: "금",
            satShort: "토",
            settings: "설정",
            done: "완료",
            cancel: "취소",
            delete: "삭제",
            edit: "편집",
            error: "오류",
            ok: "확인",
            learnTab: "학습",
            progressTab: "진도",
            loading: "로딩 중...",
            noInternetConnection: "인터넷 연결 없음",
            retry: "다시 시도")
    }

    var settings: SettingsStrings {
        SettingsStrings(
            systemLanguage: "앱 인터페이스",
            notifications: "알림",
            account: "계정",
            addLanguagePair: "언어 쌍 추가",
            logout: "로그아웃",
            nativeLanguage: "모국 어",
            selectTargetLanguage: "목표 언어 선택",
            neonGreen: "네온 그린",
            neonFuchsia: "네온 푹시아",
            electricIndigo: "일렉트릭 인디고",
            graphiteBlack: "그라파이트 블랙",
            student: "학생",
            softwareEngineer: "소프트웨어 엔지니어",
            teacher: "교사",
            doctor: "의사",
            artist: "예술가",
            businessProfessional: "비즈니스 전문가",
            salesOrMarketing: "영업 또는 마케팅",
            traveler: "여행자",
            homemaker: "주부/주부",
            chef: "셰프",
            police: "경찰",
            bankEmployee: "은행원",
            nurse: "간호사",
            designer: "디자이너",
            engineerManager: "엔지니어링 매니저",
            photographer: "사진작가",
            contentCreator: "콘텐츠 크리에이터",
            entrepreneur: "사업가",
            other: "기타",
            systemConfig: "시스템 // 설정",
            currentLevel: "현재 레벨",
            location: "위치",
            areYouSureLogout: "로그아웃하시겠습니까?",
            areYouSureDeleteAccount: "계정을 영구히 삭제하시겠습니까? 이 작업은 취소할 수 없습니다.")
    }

    var login: LoginStrings {
        LoginStrings(
            selectUserProfession: "SELECT_USER_PROFESSION",
            authenticatingUser: "AUTHENTICATING_USER...")
    }

    var onboarding: OnboardingStrings {
        OnboardingStrings(
            selectLanguageDescription: "선호 언어를 선택하세요",
            whichLanguageDoYouSpeakComfortably: "편안하게 말하는 언어는 무엇입니까?",
            chooseTheLanguageYouWantToMaster: "오늘 마스터하고 싶은 언어를 선택하세요")
    }

    var progress: ProgressStrings {
        ProgressStrings(
            addLanguagePairToSeeProgress: "진행 상황을 보려면 언어 쌍을 추가하세요",
            streakStatus: "스트릭 상태",
            chronotype: "크로노타입",
            activityDistribution: "활동 분포 (24시간)",
            earlyBird: "얼리 버드",
            earlyBirdDesc: "오전에 가장 활발함",
            dayWalker: "데이 워커",
            dayWalkerDesc: "오후에 가장 활발함",
            nightOwl: "올빼미형",
            nightOwlDesc: "밤에 가장 활발함")
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
        case .smartNotificationExactPlace: return "%@에 있다면 이 장소에 대해 읽어보세요!"
        default: return key.rawValue
        }
    }
}
