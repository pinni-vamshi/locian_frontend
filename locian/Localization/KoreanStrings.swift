//
//  KoreanStrings.swift
//  locian
//

import Foundation

struct KoreanStrings: AppStrings, LocalizedStrings {
    
    var ui: UIStrings {
        UIStrings(
            camera: "카메라",
            gallery: "갤러리",
            nextUp: "다음",
            historyLog: "기록 로그",

            moments: "순간",
            pastMoments: "지난 순간",
            noHistory: "기록 없음",
            generatingHistory: "기록 생성 중",
            generatingMoments: "생성 중...",
            analyzingImage: "이미지 분석...",
            tapNextUpToGenerate: "다음을 탭하여 생성",
            noUpcomingPlaces: "예정된 장소 없음",
            noDetails: "세부 정보 없음",
            callingAI: "Calling AI...",
            preparingLesson: "Preparing your lesson...",

            startLearning: "학습 시작",
            continueLearning: "학습 계속",
            noPastMoments: "지난 순간 없음",
            useCamera: "카메라 사용",
            previouslyLearning: "이전 학습",
            sunShort: "일",
            monShort: "월",
            tueShort: "화",
            wedShort: "수",
            thuShort: "목",
            friShort: "금",
            satShort: "토",
            login: "로그인",
            register: "등록",
            settings: "설정",
            back: "뒤로",
            done: "완료",
            cancel: "취소",
            save: "저장",
            delete: "삭제",
            add: "추가",
            remove: "제거",
            edit: "편집",
            error: "오류",
            ok: "확인",
            welcomeLabel: "환영합니다",
            currentStreak: "현재 스트리크",
            notSet: "설정되지 않음",
            learnTab: "학습",
            addTab: "추가",
            progressTab: "진도",
            settingsTab: "설정",
            loading: "로딩 중...",
            unknownPlace: "알 수 없는 장소",
            noLanguageAvailable: "사용 가능한 언어 없음",
            noInternetConnection: "인터넷 연결 없음",
            retry: "다시 시도",
            tapToGetMoments: "탭하여 현재 순간 보기",
            startLearningThisMoment: "지금 바로 학습 시작",
            daysLabel: "일",
            noNewPlace: "새 장소 추가",
            addNewPlaceInstruction: "Add a new place to get moments",
            start: "시작",
            typeYourMoment: "당신의 순간을 입력하세요...",
            imagesLabel: "이미지",
            routinesLabel: "루틴",
            whatAreYouDoing: "지금 무엇을 하고 계신가요?",
            chooseContext: "학습을 시작할 컨텍스트를 선택하세요",
            typeHere: "여기에 입력",
            nearbyLabel: "가까운",
            noNearbyPlaces: "근처에 장소를 찾을 수 없습니다")
    }

    var settings: SettingsStrings {
        SettingsStrings(
            systemLanguage: "앱 인터페이스",
            targetLanguages: "목표 언어",
            pastLanguagesArchived: "이전 학습 언어",
            theme: "테마",
            notifications: "알림",
            account: "계정",
            profile: "프로필",
            addLanguagePair: "언어 쌍 추가",
            logout: "로그아웃",
            deleteAllData: "모든 데이터 삭제",
            deleteAccount: "계정 영구 삭제",
            selectLevel: "레벨 선택",
            proFeatures: "프로 기능",
            showSimilarWordsToggle: "유사한 단어 표시",
            nativeLanguage: "모국 어",
            selectNativeLanguage: "모국어 선택",
            targetLanguage: "목표 언어",
            selectTargetLanguage: "목표 언어 선택",
            targetLanguageDescription: "배우고 싶은 언어",
            beginner: "초급",
            intermediate: "중급",
            advanced: "고급",
            currentlyLearning: "현재 학습 중",
            learnNewLanguage: "새 언어 배우기",
            learn: "학습",
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
            otherPlaces: "다른 장소",
            speaks: "사용 언어",
            neuralEngine: "뉴럴 엔진",
            noLanguagePairsAdded: "추가된 언어 쌍 없음",
            setDefault: "기본값으로 설정",
            defaultText: "기본값",
            user: "사용자",
            signOutFromAccount: "계정에서 로그아웃",
            permanentlyDeleteAccount: "계정 영구 삭제",
            languageAddedSuccessfully: "언어가 성공적으로 추가되었습니다",
            failedToAddLanguage: "언어 추가에 실패했습니다. 다시 시도해 주세요.",
            pleaseSelectLanguage: "언어를 선택하세요",
            systemConfig: "시스템 // 설정",
            currentLevel: "현재 레벨",
            selectPhoto: "사진 선택",
            camera: "카메라",
            photoLibrary: "사진 라이브러리",
            selectTime: "시간 선택",
            hour: "시간",
            minute: "분",
            addTime: "시간 추가",
            location: "위치",
            diagnosticBorders: "진단 경계",
            areYouSureLogout: "로그아웃하시겠습니까?",
            areYouSureDeleteAccount: "계정을 영구히 삭제하시겠습니까? 이 작업은 취소할 수 없습니다.")
    }

    var login: LoginStrings {
        LoginStrings(
            login: "로그인",
            verify: "확인",
            selectProfession: "직업 선택",
            selectUserProfession: "SELECT_USER_PROFESSION",
            username: "사용자 이름",
            phoneNumber: "전화번호",
            guestLogin: "게스트 로그인",
            selectProfessionInstruction: "시작하려면 직업을 선택하세요",
            showMore: "더 보기",
            showLess: "간략히 보기",
            forReview: "[검토용]",
            authenticatingUser: "AUTHENTICATING_USER...",
            bySigningInYouAgreeToOur: "By signing in, you agree to our",
            termsOfService: "TERMS_OF_SERVICE",
            privacyPolicy: "PRIVACY_POLICY"
        )
    }

    var onboarding: OnboardingStrings {
        OnboardingStrings(
            locianHeading: "Locian",
            locianDescription: "일상생활을 통해 자연스럽게 언어를 배우세요",
            awarenessHeading: "인식",
            awarenessDescription: "주변의 단어를 실시간으로 인지하세요",
            breakdownHeading: "분해",
            breakdownDescription: "단어가 어떻게 구성되는지 이해하세요",
            progressHeading: "진행",
            progressDescription: "학습 여정을 추적하세요",
            readyHeading: "준비 완료",
            readyDescription: "지금 학습을 시작하세요",
            loginOrRegister: "로그인 또는 등록",
            pageIndicator: "페이지",
            selectLanguageDescription: "선호 언어를 선택하세요",
            whichLanguageDoYouSpeakComfortably: "편안하게 말하는 언어는 무엇입니까?",
            chooseTheLanguageYouWantToMaster: "오늘 마스터하고 싶은 언어를 선택하세요",

            fromWhereYouStand: "서 있는\n곳에서",
            toEveryWord: "모든",
            everyWord: "단어로",
            youNeed: "당신에게 필요한",
            lessonEngine: "레슨_엔진",
            nodesLive: "노드_라이브",
            locEngineVersion: "LOC_ENGINE_V2.0.4",
            holoGridActive: "홀로_그리드_활성",
            adaCr02: "ADA_CR-02",
            your: "당신의",
            places: "장소,",
            lessons: "레슨.",
            yourPlaces: "당신의 장소,",
            yourLessons: " 당신의 레슨.",
            nearbyCafes: "근처 카페?",
            unlockOrderFlow: " 주문 흐름 잠금 해제",
            modules: "모듈",
            activeHubs: "활성 허브?",
            synthesizeGym: " 체육관 합성",
            vocabulary: "어휘",
            locationOpportunity: "모든 장소가 학습 기회가 됩니다",
            module03: "모듈_03",
            notJustMemorization: "단순한\n암기가 아닙니다",
            philosophy: "철학",
            locianTeaches: "Locian은 단어만 가르치지 않습니다.\nLocian은 목표 언어로 ",
            think: "생각하는 법",
            inTargetLanguage: "을 가르칩니다.",
            patternBasedLearning: "패턴 기반 학습",
            patternBasedDesc: "건조한 규칙 없이 문법 구조를 직관적으로 인식합니다.",
            situationalIntelligence: "상황 지능",
            situationalDesc: "환경과 기록에 적응하는 동적 시나리오.",
            adaptiveDrills: "적응형 드릴",
            adaptiveDesc: "레슨 엔진이 약점을 파악하고 재조정합니다.",
            systemReady: "시스템_준비",
            quickSetup: "빠른_설정",
            levelB2: "레벨_B2",
            authorized: "승인됨",
            notificationsPermission: "알림",
            notificationsDesc: "근처 연습 기회와 연속 기록 알림에 대한 실시간 업데이트를 받으세요.",
            microphonePermission: "마이크",
            microphoneDesc: "실제 상황에서의 발음 채점 및 레슨 상호 작용에 필수적입니다.",
            geolocationPermission: "위치",
            geolocationDesc: "몰입형 연습을 위해 카페나 도서관 같은 근처 \"레슨 구역\"을 식별합니다.",
            granted: "허용됨",
            allow: "허용",
            skip: "건너뛰기",
            letsStart: "시작합시다",
            continueText: "계속",
            wordTenses: "단어 시제:",
            similarWords: "비슷한 단어:",
            wordBreakdown: "단어 분해:",
            consonant: "자음",
            vowel: "모음",
            past: "과거",
            present: "현재",
            future: "미래",
            learnWord: "학습")
    }

    var progress: ProgressStrings {
        ProgressStrings(
            progress: "진행 상황",
            current: "현재",
            longest: "최장",
            lastPracticed: "마지막 연습",
            days: "일",
            addLanguagePairToSeeProgress: "진행 상황을 보려면 언어 쌍을 추가하세요",
            startPracticingMessage: "연속 기록을 쌓으려면 연습을 시작하세요",
            consistencyQuote: "일관성은 언어 학습의 핵심입니다",
            practiceDateSavingDisabled: "연습 날짜 저장이 비활성화되었습니다",
            editYourStreaks: "연속 기록 편집",
            editStreaks: "연속 기록 편집",
            selectDatesToAddOrRemove: "연속 기록에서 추가하거나 제거할 날짜를 선택하세요",
            saving: "저장 중",
            statusOnFire: "상태: 최고조",
            youPracticed: "연습했습니다 ",
            yesterday: " 어제.",
            checkInNow: "지금 체크인",
            nextGoal: "다음 목표",
            reward: "보상",
            historyLogProgress: "역사 로그",
            streakStatus: "스트릭 상태",
            streakLog: "스트릭 로그",
            consistency: "일관성",
            consistencyHigh: "활동 로그가 높은 참여도를 보여줍니다.",
            consistencyMedium: "좋은 추진력을 구축하고 있습니다.",
            consistencyLow: "일관성이 핵심입니다. 계속 추진하세요.",
            reachMilestone: "%d일에 도달하도록 노력해보세요!",
            nextMilestone: "다음 마일스톤",
            actionRequired: "조치 필요",
            logActivity: "활동 기록",
            maintainStreak: "Maintain Streak",
            manualEntry: "Manual Entry",
            longestStreakLabel: "최장 스트릭",
            streakData: "스트릭 데이터",
            activeLabel: "활성",
            missedLabel: "실패",
            saveChanges: "변경 사항 저장",
            discardChanges: "변경 사항 취소",
            editLabel: "편집",
            // Advanced Stats
            skillBalance: "기술 균형",
            fluencyVelocity: "유창성 속도",
            vocabVault: "어휘 저장소",
            chronotype: "크로노타입",
            activityDistribution: "활동 분포 (24시간)",
            studiedTime: "학습 시간",
            currentLabel: "현재",
            streakLabel: "스트릭",
            longestLabel: "최장",
            earlyBird: "얼리 버드",
            earlyBirdDesc: "오전에 가장 활발함",
            dayWalker: "데이 워커",
            dayWalkerDesc: "오후에 가장 활발함",
            nightOwl: "올빼미형",
            nightOwlDesc: "밤에 가장 활발함",
            timeMastery: "시간 숙달",
            wordsMastered: "Words Mastered",
            patternsMastered: "Patterns Active",
            avgResponseTime: "Avg Response Time",
            patternGalaxy: "PATTERN GALAXY")
    }

    var quiz: QuizStrings {
        QuizStrings(            loading: "로딩 중...",
            adaptiveQuiz: "적응형 퀴즈",
            adaptiveQuizDescription: "오답을 먼저 보여준 다음 정답을 강조합니다.",
            wordCheck: "단어 확인",
            wordCheckDescription: "타일이 섞인 후 제자리에 맞춰져 정답을 확인합니다.",
            wordCheckExamplePrompt: "문자를 탭하여 단어를 올바른 순서로 배열하세요.",
            quizPrompt: "단어의 올바른 번역을 선택하세요.",
            answerConfirmation: "올바른 단어를 만들었습니다!",
            tryAgain: "이런! 다시 시도하세요.")
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
        case .login: return ui.login
        case .register: return ui.register
        case .settings: return ui.settings
        case .back: return ui.back
        case .done: return ui.done
        case .cancel: return ui.cancel
        case .save: return ui.save
        case .delete: return ui.delete
        case .add: return ui.add
        case .remove: return ui.remove
        case .edit: return ui.edit
        case .learnTab: return ui.learnTab
        case .addTab: return ui.addTab
        case .progressTab: return ui.progressTab
        case .settingsTab: return ui.settingsTab
        case .loading: return ui.loading
        case .user: return settings.user
        case .unknownPlace: return ui.unknownPlace
        case .noLanguageAvailable: return ui.noLanguageAvailable
        case .noInternetConnection: return ui.noInternetConnection
        case .retry: return ui.retry
        case .tapToGetMoments: return ui.tapToGetMoments
        case .startLearningThisMoment: return ui.startLearningThisMoment
        case .daysLabel: return ui.daysLabel
        case .systemLanguage: return settings.systemLanguage
        case .targetLanguages: return settings.targetLanguages
        case .pastLanguagesArchived: return settings.pastLanguagesArchived
        case .theme: return settings.theme
        case .logout: return settings.logout
        case .learnNewLanguage: return settings.learnNewLanguage
        case .profile: return settings.profile
        case .addLanguagePair: return settings.addLanguagePair
        case .deleteAllData: return settings.deleteAllData
        case .deleteAccount: return settings.deleteAccount
        case .selectLevel: return settings.selectLevel
        case .proFeatures: return settings.proFeatures
        case .showSimilarWordsToggle: return settings.showSimilarWordsToggle
        case .cameraLabel: return ui.camera
        case .galleryLabel: return ui.gallery
        case .nextUp: return ui.nextUp
        case .historyLog: return ui.historyLog

        case .moments: return ui.moments
        case .pastMoments: return ui.pastMoments
        case .welcomeLabel: return ui.welcomeLabel
        case .noUpcomingPlaces: return ui.noUpcomingPlaces
        case .noDetailsRecorded: return ui.noDetails

        case .startLearningLabel: return ui.startLearning
        case .continueLearningLabel: return ui.continueLearning
        case .noPastMomentsFor: return ui.noPastMoments
        case .useCameraToStartLearning: return ui.useCamera
        case .previouslyLearning: return ui.previouslyLearning
        case .noHistoryRecorded: return ui.noHistory
        case .tapNextUpToGenerate: return ui.tapNextUpToGenerate
        case .generatingHistory: return ui.generatingHistory
        case .generatingMoments: return ui.generatingMoments
        case .analyzingImage: return ui.analyzingImage
        case .noNewPlace: return ui.noNewPlace
        case .addNewPlaceInstruction: return ui.addNewPlaceInstruction
        case .start: return ui.start
        case .startPracticingMessage: return progress.startPracticingMessage
        case .consistencyQuote: return progress.consistencyQuote
        case .practiceDateSavingDisabled: return progress.practiceDateSavingDisabled
        case .sunShort: return ui.sunShort
        case .monShort: return ui.monShort
        case .tueShort: return ui.tueShort
        case .wedShort: return ui.wedShort
        case .thuShort: return ui.thuShort
        case .friShort: return ui.friShort
        case .satShort: return ui.satShort
        case .noLanguagePairsAdded: return settings.noLanguagePairsAdded
        case .setDefault: return settings.setDefault
        case .defaultText: return settings.defaultText
        case .signOutFromAccount: return settings.signOutFromAccount
        case .permanentlyDeleteAccount: return settings.permanentlyDeleteAccount
        case .currentLevel: return settings.currentLevel
        case .selectPhoto: return settings.selectPhoto
        case .camera: return settings.camera
        case .photoLibrary: return settings.photoLibrary
        case .selectTime: return settings.selectTime
        case .hour: return settings.hour
        case .minute: return settings.minute
        case .addTime: return settings.addTime
        case .areYouSureLogout: return settings.areYouSureLogout
        case .areYouSureDeleteAccount: return settings.areYouSureDeleteAccount
        case .nativeLanguage: return settings.nativeLanguage
        case .selectNativeLanguage: return settings.selectNativeLanguage
        case .targetLanguage: return settings.targetLanguage
        case .selectTargetLanguage: return settings.selectTargetLanguage
        case .targetLanguageDescription: return settings.targetLanguageDescription
        case .beginner: return settings.beginner
        case .intermediate: return settings.intermediate
        case .advanced: return settings.advanced
        case .currentlyLearning: return settings.currentlyLearning
        case .learn: return settings.learn
        case .neonGreen: return settings.neonGreen
        case .neonFuchsia: return settings.neonFuchsia
        case .electricIndigo: return settings.electricIndigo
        case .graphiteBlack: return settings.graphiteBlack
        case .error: return ui.error
        case .ok: return ui.ok
        case .locianHeading: return onboarding.locianHeading
        case .locianDescription: return onboarding.locianDescription
        case .awarenessHeading: return onboarding.awarenessHeading
        case .awarenessDescription: return onboarding.awarenessDescription
        case .breakdownHeading: return onboarding.breakdownHeading
        case .breakdownDescription: return onboarding.breakdownDescription
        case .progressHeading: return onboarding.progressHeading
        case .progressDescription: return onboarding.progressDescription
        case .readyHeading: return onboarding.readyHeading
        case .readyDescription: return onboarding.readyDescription
        case .loginOrRegister: return onboarding.loginOrRegister
        case .pageIndicator: return onboarding.pageIndicator
        case .selectLanguageDescription: return onboarding.selectLanguageDescription
        case .whichLanguageDoYouSpeakComfortably: return onboarding.whichLanguageDoYouSpeakComfortably
        case .chooseTheLanguageYouWantToMaster: return onboarding.chooseTheLanguageYouWantToMaster
        case .wordTenses: return onboarding.wordTenses
        case .similarWords: return onboarding.similarWords
        case .wordBreakdown: return onboarding.wordBreakdown
        case .consonant: return onboarding.consonant
        case .vowel: return onboarding.vowel
        case .adaptiveQuiz: return quiz.adaptiveQuiz
        case .adaptiveQuizDescription: return quiz.adaptiveQuizDescription
        case .wordCheck: return quiz.wordCheck
        case .wordCheckDescription: return quiz.wordCheckDescription
        case .wordCheckExamplePrompt: return quiz.wordCheckExamplePrompt
        case .quizPrompt: return quiz.quizPrompt
        case .answerConfirmation: return quiz.answerConfirmation
        case .tryAgain: return quiz.tryAgain
        case .verify: return login.verify
        case .selectProfession: return login.selectProfession
        case .selectProfessionInstruction: return login.selectProfessionInstruction
        case .showMore: return login.showMore
        case .showLess: return login.showLess
        case .forReview: return login.forReview
        case .username: return login.username
        case .phoneNumber: return login.phoneNumber
        case .guestLogin: return login.guestLogin
        case .authenticatingUser: return login.authenticatingUser
        case .bySigningInYouAgreeToOur: return login.bySigningInYouAgreeToOur
        case .termsOfService: return login.termsOfService
        case .privacyPolicy: return login.privacyPolicy
        case .selectUserProfession: return login.selectUserProfession
        case .editYourStreaks: return progress.editYourStreaks
        case .editStreaks: return progress.editStreaks
        case .selectDatesToAddOrRemove: return progress.selectDatesToAddOrRemove
        case .saving: return progress.saving
        case .student: return settings.student
        case .softwareEngineer: return settings.softwareEngineer
        case .teacher: return settings.teacher
        case .doctor: return settings.doctor
        case .artist: return settings.artist
        case .businessProfessional: return settings.businessProfessional
        case .salesOrMarketing: return settings.salesOrMarketing
        case .traveler: return settings.traveler
        case .activityDistribution: return progress.activityDistribution
        case .studiedTime: return progress.studiedTime
        case .currentLabel: return progress.currentLabel
        case .streakLabel: return progress.streakLabel
        case .longestLabel: return progress.longestLabel
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
        case .otherPlaces: return settings.otherPlaces
        case .speaks: return settings.speaks
        case .neuralEngine: return settings.neuralEngine
        case .currentStreak: return ui.currentStreak
        case .notSet: return ui.notSet
        case .past: return onboarding.past
        case .present: return onboarding.present
        case .future: return onboarding.future
        case .learnWord: return onboarding.learnWord
        case .languageAddedSuccessfully: return settings.languageAddedSuccessfully
        case .failedToAddLanguage: return settings.failedToAddLanguage
        case .pleaseSelectLanguage: return settings.pleaseSelectLanguage
        case .systemConfig: return settings.systemConfig
        case .statusOnFire: return progress.statusOnFire
        case .youPracticed: return progress.youPracticed
        case .yesterday: return progress.yesterday
        case .checkInNow: return progress.checkInNow
        case .nextGoal: return progress.nextGoal
        case .reward: return progress.reward
        case .historyLogProgress: return progress.historyLogProgress
        case .streakStatus: return progress.streakStatus
        case .streakLog: return progress.streakLog
        case .consistency: return progress.consistency
        case .consistencyHigh: return progress.consistencyHigh
        case .consistencyMedium: return progress.consistencyMedium
        case .consistencyLow: return progress.consistencyLow
        case .progress: return progress.progress
        case .current: return progress.current
        case .longest: return progress.longest
        case .days: return progress.days
        case .reachMilestone: return progress.reachMilestone
        case .nextMilestone: return progress.nextMilestone
        case .actionRequired: return progress.actionRequired
        case .logActivity: return progress.logActivity
        case .maintainStreak: return progress.maintainStreak
        case .manualEntry: return progress.manualEntry
        case .longestStreakLabel: return progress.longestStreakLabel
        case .streakData: return progress.streakData
        case .activeLabel: return progress.activeLabel
        case .missedLabel: return progress.missedLabel
        case .saveChanges: return progress.saveChanges
        case .discardChanges: return progress.discardChanges
        case .editLabel: return progress.editLabel
        case .lastPracticed: return progress.lastPracticed
        case .addLanguagePairToSeeProgress: return progress.addLanguagePairToSeeProgress
        case .callingAI: return ui.callingAI
        case .preparingLesson: return ui.preparingLesson
        
        case .module03: return onboarding.module03
        case .notJustMemorization: return onboarding.notJustMemorization
        case .philosophy: return onboarding.philosophy
        case .locianTeaches: return onboarding.locianTeaches
        case .think: return onboarding.think
        case .inTargetLanguage: return onboarding.inTargetLanguage
        case .patternBasedLearning: return onboarding.patternBasedLearning
        case .patternBasedDesc: return onboarding.patternBasedDesc
        case .situationalIntelligence: return onboarding.situationalIntelligence
        case .situationalDesc: return onboarding.situationalDesc
        case .adaptiveDrills: return onboarding.adaptiveDrills
        case .adaptiveDesc: return onboarding.adaptiveDesc
        case .systemReady: return onboarding.systemReady
        case .quickSetup: return onboarding.quickSetup
        case .levelB2: return onboarding.levelB2
        case .authorized: return onboarding.authorized
        case .notificationsPermission: return onboarding.notificationsPermission
        case .notificationsDesc: return onboarding.notificationsDesc
        case .microphonePermission: return onboarding.microphonePermission
        case .microphoneDesc: return onboarding.microphoneDesc
        case .geolocationPermission: return onboarding.geolocationPermission
        case .geolocationDesc: return onboarding.geolocationDesc
        case .granted: return onboarding.granted
        case .allow: return onboarding.allow
        case .skip: return onboarding.skip
        case .letsStart: return onboarding.letsStart
        case .continueText: return onboarding.continueText
        case .fromWhereYouStand: return onboarding.fromWhereYouStand
        case .toEveryWord: return onboarding.toEveryWord
        case .everyWord: return onboarding.everyWord
        case .youNeed: return onboarding.youNeed
        case .lessonEngine: return onboarding.lessonEngine
        case .nodesLive: return onboarding.nodesLive
        case .locEngineVersion: return onboarding.locEngineVersion
        case .holoGridActive: return onboarding.holoGridActive
        case .adaCr02: return onboarding.adaCr02
        case .your: return onboarding.your
        case .places: return onboarding.places
        case .lessons: return onboarding.lessons
        case .yourPlaces: return onboarding.yourPlaces
        case .yourLessons: return onboarding.yourLessons
        case .nearbyCafes: return onboarding.nearbyCafes
        case .unlockOrderFlow: return onboarding.unlockOrderFlow
        case .modules: return onboarding.modules
        case .activeHubs: return onboarding.activeHubs
        case .synthesizeGym: return onboarding.synthesizeGym
        case .vocabulary: return onboarding.vocabulary
        case .locationOpportunity: return onboarding.locationOpportunity
        // Advanced Stats
        case .skillBalance: return progress.skillBalance
        case .fluencyVelocity: return progress.fluencyVelocity
        case .vocabVault: return progress.vocabVault
        case .chronotype: return progress.chronotype
        case .timeMastery: return progress.timeMastery
        case .wordsMastered: return progress.wordsMastered
        case .patternsMastered: return progress.patternsMastered
        case .avgResponseTime: return progress.avgResponseTime
        case .patternGalaxy: return progress.patternGalaxy
        case .typeYourMoment: return ui.typeYourMoment
        case .imagesLabel: return ui.imagesLabel
        case .routinesLabel: return ui.routinesLabel
        case .whatAreYouDoing: return ui.whatAreYouDoing
        case .chooseContext: return ui.chooseContext
        case .typeHere: return ui.typeHere
        case .nearbyLabel: return ui.nearbyLabel
        case .noNearbyPlaces: return ui.noNearbyPlaces
        }
    }
}
