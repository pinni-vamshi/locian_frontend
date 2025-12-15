//
//  KoreanStrings.swift
//  locian
//
//  Korean localization strings
//

import Foundation

struct KoreanStrings: AppStrings, LocalizedStrings {
    var quiz: QuizStrings {
        QuizStrings(
            completed: "퀴즈 완료!",
            masteredEnvironment: "환경을 마스터했습니다!",
            learnMoreAbout: "에 대해 더 알아보기",
            backToHome: "홈으로 돌아가기",
            next: "다음",
            previous: "이전",
            check: "확인",
            tryAgain: "다시 시도",
            shuffled: "섞였습니다",
            noQuizAvailable: "사용 가능한 퀴즈 없음",
            question: "문제",
            correct: "정답",
            incorrect: "오답",
            notAttempted: "시도하지 않음"
        )
    }
    
    var settings: SettingsStrings {
        SettingsStrings(
            languagePairs: "내 언어",
            notifications: "알림",
            appearance: "미학",
            account: "계정",
            profile: "프로필",
            addLanguagePair: "언어 쌍 추가",
            enableNotifications: "알림 활성화",
            logout: "로그아웃",
            deleteAllData: "모든 데이터 삭제",
            deleteAccount: "계정 삭제",
            selectLevel: "레벨 선택",
            selectAppLanguage: "앱 인터페이스",
            proFeatures: "프로 기능",
            showSimilarWordsToggle: "유사 단어 표시",
            showWordTensesToggle: "단어 시제 표시",
            nativeLanguage: "모국어:",
            selectNativeLanguage: "모국어를 선택하세요",
            targetLanguage: "목표 언어:",
            selectTargetLanguage: "학습하고 싶은 언어를 선택하세요",
            nativeLanguageDescription: "모국어는 읽기, 쓰기, 말하기를 유창하게 할 수 있는 언어입니다. 가장 편안하게 느끼는 언어입니다.",
            targetLanguageDescription: "목표 언어는 학습하고 연습하고 싶은 언어입니다. 실력을 향상시키고 싶은 언어를 선택하세요.",
            addPair: "쌍 추가",
            adding: "추가 중...",
            failedToAddLanguagePair: "언어 쌍 추가에 실패했습니다. 다시 시도해 주세요.",
            settingAsDefault: "기본값으로 설정 중...",
            beginner: "초급",
            intermediate: "중급",
            advanced: "고급",
            currentlyLearning: "학습 중",
            otherLanguages: "기타 언어",
            learnNewLanguage: "새 언어 배우기",
            learn: "배우기",
            tapToSelectNativeLanguage: "모국어를 선택하려면 탭하세요",
            neonGreen: "네온 그린",
            cyanMist: "시안 미스트",
            violetHaze: "바이올렛 헤이즈",
            softPink: "소프트 핑크",
            pureWhite: "순백색"
        )
    }
    
    var vocabulary: VocabularyStrings {
        VocabularyStrings(
            exploreCategories: "카테고리 탐색",
            testYourself: "자신을 테스트",
            slideToStartQuiz: "퀴즈 시작을 위해 슬라이드",
            similarWords: "유사한 단어",
            wordTenses: "단어 시제",
            wordBreakdown: "단어 분해",
            tapToSeeBreakdown: "단어 분해를 보려면 탭",
            tapToHideBreakdown: "단어 분해를 숨기려면 탭",
            tapWordsToExplore: "단어를 탭하여 번역을 읽고 탐색하세요",
            loading: "로딩 중...",
            learnTheWord: "단어 배우기",
            tryFromMemory: "기억에서 시도",
            adjustingTo: "조정 중",
            settingPlace: "설정 중",
            settingTime: "설정 중",
            generatingVocabulary: "생성 중",
            analyzingVocabulary: "분석 중",
            analyzingCategories: "분석 중",
            analyzingWords: "분석 중",
            creatingQuiz: "생성 중",
            organizingContent: "정리 중",
            to: "에",
            place: "장소",
            time: "시간",
            vocabulary: "어휘",
            your: "당신의",
            interested: "관심있는",
            categories: "카테고리",
            words: "단어",
            quiz: "퀴즈",
            content: "내용"
        )
    }
    
    var scene: SceneStrings {
        SceneStrings(
            hi: "안녕하세요,",
            learnFromSurroundings: "주변에서 배우기",
            learnFromSurroundingsDescription: "환경을 캡처하고 실제 상황에서 어휘를 배우세요",
            locianChoosing: "선택 중...",
            chooseLanguages: "언어를 선택하세요",
            continueWith: "Locian이 선택한 것으로 계속",
            slideToLearn: "학습을 위해 슬라이드",
            recommended: "추천",
            intoYourLearningFlow: "학습 흐름으로",
            intoYourLearningFlowDescription: "학습 기록을 기반으로 연습할 추천 장소",
            customSituations: "사용자 지정 상황",
            customSituationsDescription: "자신만의 개인화된 학습 시나리오를 만들고 연습하세요",
            max: "최대",
            recentPlacesTitle: "최근 장소",
            allPlacesTitle: "모든 장소",
            recentPlacesEmpty: "어휘를 생성하면 추천이 표시됩니다.",
            showMore: "더 보기",
            showLess: "접기",
            takePhoto: "사진 찍기",
            chooseFromGallery: "갤러리에서 선택",
            letLocianChoose: "Locian이 선택하도록 하기",
            lociansChoice: "Locian 제공",
            cameraTileDescription: "이 사진은 환경을 분석하고 학습할 수 있는 순간을 보여줍니다.",
            airport: "공항",
            aquarium: "아쿠아리움",
            bakery: "빵집",
            beach: "해변",
            bookstore: "서점",
            cafe: "카페",
            cinema: "영화관",
            gym: "체육관",
            hospital: "병원",
            hotel: "호텔",
            home: "집",
            library: "도서관",
            market: "시장",
            museum: "박물관",
            office: "사무실",
            park: "공원",
            restaurant: "레스토랑",
            shoppingMall: "쇼핑몰",
            stadium: "경기장",
            supermarket: "슈퍼마켓",
            temple: "사원",
            travelling: "여행",
            university: "대학교",
            addCustomPlace: "사용자 지정 장소 추가",
            addPlace: "장소 추가",
            enterCustomPlaceName: "사용자 지정 장소 이름을 입력하세요 (최대 30자)",
            maximumCustomPlaces: "최대 10개의 사용자 지정 장소",
            welcome: "환영합니다",
            user: "사용자",
            tapToCaptureContext: "탭하여 컨텍스트를 캡처하고 학습을 시작하세요",
            customSection: "사용자 지정",
            examples: "예:",
            customPlacePlaceholder: "예: 사무실로 이동",
            exampleTravellingToOffice: "사무실로 이동",
            exampleTravellingToHome: "집으로 이동",
            exampleExploringParis: "파리 탐험",
            exampleVisitingMuseum: "박물관 방문",
            exampleCoffeeShop: "커피숍",
            characterCount: "자",
            situationExample1: "바쁜 카페에서 커피 주문하기",
            situationExample2: "새로운 도시에서 길 묻기",
            situationExample3: "시장에서 식료품 쇼핑하기",
            situationExample4: "의사 예약하기",
            situationExample5: "호텔 체크인하기"
        )
    }
    
    var login: LoginStrings {
        LoginStrings(
            login: "로그인",
            verify: "확인",
            selectProfession: "직업 선택",
            username: "사용자 이름",
            phoneNumber: "전화번호",
            guestLogin: "게스트 로그인",
            guestLoginDescription: ""
        )
    }
    
    var onboarding: OnboardingStrings {
        OnboardingStrings(
            locianHeading: "Locian",
            locianDescription: "당신이 서 있는 곳에서 필요한 모든 시제까지",
            awarenessHeading: "인식",
            awarenessDescription: "AI가 당신의 주변 환경에서 학습합니다",
            inputsHeading: "입력",
            inputsDescription: "Locian surfaces similar words, word tenses, and full word breakdowns—not just consonant and vowel charts",
            breakdownHeading: "분해",
            breakdownDescription: "Locian은 문장을 시제로 분해하고 단어별 번역을 제공합니다",
            progressHeading: "Quiz",
            progressDescription: "Preview the rebuild puzzle, adaptive quizzes, and smart shuffle that keep practice fresh",
            readyHeading: "준비됨",
            readyDescription: "",
            loginOrRegister: "로그인 / 등록",
            pageIndicator: " / 6",
            tapToNavigate: "왼쪽 또는 오른쪽을 탭하여 탐색",
            selectAppLanguage: "앱 언어 선택",
            selectLanguageDescription: "이 언어는 앱 사용자 인터페이스, 제목, 설명, 버튼, 이름 및 모든 것을 선택한 언어로 변경합니다"
        )
    }
    
    var common: CommonStrings {
        CommonStrings(
            cancel: "취소",
            save: "저장",
            done: "완료",
            ok: "확인",
            back: "뒤로",
            next: "다음",
            continueText: "계속"
        )
    }
    
    var customPractice: CustomPracticeStrings {
        CustomPracticeStrings(
            custom: "사용자 지정",
            hint: "힌트",
            practiceDescription: "아무 단어나 탭하여 목표 언어로 번역하세요. 도움이 필요하면 힌트 버튼을 사용하여 제안을 받으세요.",
            practiceTitle: "연습",
            practiceFollowUp: "다음 연습",
            camera: "카메라",
            cameraDescription: "Locian은 {native}로 대화를 생성하고 {target}로 변환하는 연습을 할 수 있습니다.",
            useCamera: "카메라 사용",
            cameraButtonDescription: "사진에서 순간 생성",
            typeConversation: "대화 입력",
            typeConversationDescription: "Locian은 {native}로 대화를 생성하고 {target}로 변환하는 연습을 할 수 있습니다.",
            conversationPlaceholder: "예: 바쁜 카페에서 커피 주문하기",
            submit: "제출",
            fullCustomText: "전체 사용자 지정 텍스트",
            examples: "예:",
            conversationExample1: "비 오는 날 길 묻기",
            conversationExample2: "늦은 밤 야채 사기",
            conversationExample3: "붐비는 사무실에서 일하기",
            describeConversation: "Locian이 만들 대화를 설명하세요.",
            fullTextPlaceholder: "전체 텍스트 또는 대화를 여기에 입력...",
            startCustomPractice: "사용자 지정 연습 시작"
        )
    }
    
    var progress: ProgressStrings {
        ProgressStrings(
            progress: "진행 상황",
            edit: "편집",
            current: "현재",
            longest: "가장 긴",
            lastPracticed: "마지막 연습",
            days: "일",
            addLanguagePairToSeeProgress: "진행 상황을 보려면 언어 쌍을 추가하세요."
        )
    }
    
    func getString(_ key: String) -> String {
        return key
    }
    
    // Also implement LocalizedStrings protocol
    func getString(for key: StringKey) -> String {
        switch key {
        // Settings
        case .languagePairs: return "내 언어"
        case .notifications: return "알림"
        case .aesthetics: return "미학"
        case .account: return "계정"
        case .appLanguage: return "앱 인터페이스"
        
        // Common
        case .login: return "로그인 /"
        case .register: return "등록"
        case .settings: return "설정"
        case .home: return "홈"
        case .back: return "뒤로"
        case .next: return "다음"
        case .previous: return "이전"
        case .done: return "완료"
        case .cancel: return "취소"
        case .save: return "저장"
        case .delete: return "삭제"
        case .add: return "추가"
        case .remove: return "제거"
        case .edit: return "편집"
        case .continueText: return "계속"
        
        // Quiz
        case .quizCompleted: return "퀴즈 완료!"
        case .sessionCompleted: return "세션 완료!"
        case .masteredEnvironment: return "환경을 마스터했습니다!"
        case .learnMoreAbout: return "에 대해 더 알아보기"
        case .backToHome: return "홈으로 돌아가기"
        case .tryAgain: return "다시 시도"
        case .shuffled: return "섞였습니다"
        case .check: return "확인"
        
        // Vocabulary
        case .exploreCategories: return "카테고리 탐색"
        case .testYourself: return "자신을 테스트"
        case .similarWords: return "유사한 단어:"
        case .wordTenses: return "단어 시제:"
        case .tapWordsToExplore: return "단어를 탭하여 번역을 읽고 탐색하세요"
        case .wordBreakdown: return "단어 분석:"
        
        // Scene
        case .analyzingImage: return "이미지 분석 중..."
        case .imageAnalysisCompleted: return "이미지 분석 완료"
        case .imageSelected: return "이미지 선택됨"
        case .placeNotSelected: return "장소가 선택되지 않음"
        case .locianChoose: return "Locian이 선택"
        case .chooseLanguages: return "언어를 선택하세요"
        
        // Settings
        case .enableNotifications: return "알림 활성화"
        case .thisPlace: return "이 곳"
        case .tapOnAnySection: return "위의 섹션을 탭하여 설정을 보고 관리하세요"
        case .addNewLanguagePair: return "새 언어 쌍 추가"
        case .noLanguagePairsAdded: return "아직 언어 쌍이 추가되지 않았습니다"
        case .setDefault: return "기본값으로 설정"
        case .defaultText: return "기본값"
        case .user: return "사용자"
        case .noPhone: return "전화 없음"
        case .signOutFromAccount: return "계정에서 로그아웃"
        case .removeAllPracticeData: return "모든 연습 데이터 제거"
        case .permanentlyDeleteAccount: return "계정 및 모든 데이터 영구 삭제"
        case .currentLevel: return "현재 레벨"
        case .selectPhoto: return "사진 선택"
        case .camera: return "카메라"
        case .photoLibrary: return "사진 라이브러리"
        case .selectTime: return "시간 선택"
        case .hour: return "시간"
        case .minute: return "분"
        case .addTime: return "시간 추가"
        case .areYouSureLogout: return "정말 로그아웃하시겠습니까?"
        case .areYouSureDeleteAccount: return "정말 계정을 삭제하시겠습니까? 이 작업은 취소할 수 없습니다."
        
        // Quiz
        case .goBack: return "돌아가기"
        case .fillInTheBlank: return "빈칸 채우기:"
        case .arrangeWordsInOrder: return "단어를 올바른 순서로 배열:"
        case .tapWordsBelowToAdd: return "아래 단어를 탭하여 여기에 추가"
        case .availableWords: return "사용 가능한 단어:"
        case .correctAnswer: return "정답:"
        
        // Common
        case .error: return "오류"
        case .ok: return "확인"
        case .close: return "닫기"
        
        // Onboarding
        case .locianHeading: return "Locian"
        case .locianDescription: return "당신이 서 있는 곳에서 필요한 모든 시제까지"
        case .awarenessHeading: return "인식"
        case .awarenessDescription: return "AI가 당신의 주변 환경에서 학습합니다"
        case .inputsHeading: return "입력"
        case .inputsDescription: return "Locian surfaces similar words, word tenses, and full word breakdowns—not just consonant and vowel charts"
        case .breakdownHeading: return "분해"
        case .breakdownDescription: return "Locian은 문장을 시제로 분해하고 단어별 번역을 제공합니다"
        case .progressHeading: return "Quiz"
        case .progressDescription: return "Preview the rebuild mini-game, adaptive quizzes, and smart shuffle that keep practice fresh"
        case .readyHeading: return "준비됨"
        case .readyDescription: return ""
        
        // Onboarding additional strings
        case .loginOrRegister: return "로그인 / 등록"
        case .pageIndicator: return " / 6"
        case .tapToNavigate: return "왼쪽 또는 오른쪽을 탭하여 탐색"
        case .selectAppLanguage: return "앱 언어 선택"
        case .selectLanguageDescription: return "이 언어는 앱 사용자 인터페이스, 제목, 설명, 버튼, 이름 및 모든 것을 선택한 언어로 변경합니다"
        
        // Login
        case .username: return "사용자 이름"
        case .phoneNumber: return "전화번호"
        case .guestLogin: return "게스트 로그인"
        case .guestLoginDescription: return "게스트 로그인은 검증을 위한 것이며 게스트가 모든 앱 기능에 액세스할 수 있도록 합니다. 검증 후 제거됩니다."
        
        // Professions
        case .student: return "학생"
        case .softwareEngineer: return "소프트웨어 엔지니어"
        case .teacher: return "교사"
        case .doctor: return "의사"
        case .artist: return "예술가"
        case .businessProfessional: return "비즈니스 전문가"
        case .salesOrMarketing: return "영업 또는 마케팅"
        case .traveler: return "여행자"
        case .homemaker: return "주부"
        case .chef: return "셰프"
        case .police: return "경찰"
        case .bankEmployee: return "은행 직원"
        case .nurse: return "간호사"
        case .designer: return "디자이너"
        case .engineerManager: return "엔지니어 매니저"
        case .photographer: return "사진작가"
        case .contentCreator: return "콘텐츠 크리에이터"
        case .other: return "기타"
        
        // Scene Places
        case .lociansChoice: return "Locian의 선택"
        case .airport: return "공항"
        case .cafe: return "카페"
        case .gym: return "체육관"
        case .library: return "도서관"
        case .office: return "사무실"
        case .park: return "공원"
        case .restaurant: return "레스토랑"
        case .shoppingMall: return "쇼핑몰"
        case .travelling: return "여행"
        case .university: return "대학교"
        case .addCustomPlace: return "사용자 지정 장소 추가"
        case .enterCustomPlaceName: return "사용자 지정 장소 이름을 입력하세요 (최대 30자)"
        case .maximumCustomPlaces: return "최대 10개의 사용자 지정 장소"
        case .welcome: return "환영합니다"
        case .tapToCaptureContext: return "탭하여 컨텍스트를 캡처하고 학습을 시작하세요"
        case .customSection: return "사용자 지정"
        case .examples: return "예:"
        case .customPlacePlaceholder: return "예: 사무실로 이동"
        case .exampleTravellingToOffice: return "사무실로 이동"
        case .exampleTravellingToHome: return "집으로 이동"
        case .exampleExploringParis: return "파리 탐험"
        case .exampleVisitingMuseum: return "박물관 방문"
        case .exampleCoffeeShop: return "커피숍"
        case .characterCount: return "자"
        
        // Settings Modal Strings
        case .nativeLanguage: return "모국어:"
        case .selectNativeLanguage: return "모국어를 선택하세요"
        case .targetLanguage: return "목표 언어:"
        case .selectTargetLanguage: return "학습하고 싶은 언어를 선택하세요"
        case .nativeLanguageDescription: return "모국어는 읽기, 쓰기, 말하기를 유창하게 할 수 있는 언어입니다. 가장 편안하게 느끼는 언어입니다."
        case .targetLanguageDescription: return "목표 언어는 학습하고 연습하고 싶은 언어입니다. 실력을 향상시키고 싶은 언어를 선택하세요."
        case .addPair: return "쌍 추가"
        case .adding: return "추가 중..."
        case .failedToAddLanguagePair: return "언어 쌍 추가에 실패했습니다. 다시 시도해 주세요."
        case .settingAsDefault: return "기본값으로 설정 중..."
        case .beginner: return "초급"
        case .intermediate: return "중급"
        case .advanced: return "고급"
        case .currentlyLearning: return "학습 중"
        case .otherLanguages: return "기타 언어"
        case .learnNewLanguage: return "새 언어 배우기"
        case .learn: return "배우기"
        case .tapToSelectNativeLanguage: return "모국어를 선택하려면 탭하세요"
        case .neonGreen: return "네온 그린"
        
        // Theme color names
        case .cyanMist: return "시안 미스트"
        case .violetHaze: return "바이올렛 헤이즈"
        case .softPink: return "소프트 핑크"
        case .pureWhite: return "순백색"
        
        // Quick Look
        case .quickRecall: return "빠른 회상"
        case .startQuickPuzzle: return "빠른 퍼즐 시작"
        case .stopPuzzle: return "퍼즐 중지"
        
        // Streak
        case .streak: return "연속"
        case .dayStreak: return "일 연속"
        case .daysStreak: return "일 연속"
        case .editYourStreaks: return "연속 기록 편집"
        case .editStreaks: return "연속 기록 편집"
        case .selectDatesToAddOrRemove: return "연습일을 추가하거나 제거할 날짜 선택"
        case .saving: return "저장 중..."
        }
    }
}

