//
//  ChineseStrings.swift
//  locian
//
//  Chinese localization strings
//

import Foundation

struct ChineseStrings: AppStrings, LocalizedStrings {
    var quiz: QuizStrings {
        QuizStrings(
            completed: "测验完成！",
            masteredEnvironment: "您已经掌握了您的环境！",
            learnMoreAbout: "了解更多关于",
            backToHome: "返回首页",
            next: "下一步",
            previous: "上一步",
            check: "检查",
            tryAgain: "再试一次",
            shuffled: "已打乱",
            noQuizAvailable: "没有可用的测验",
            question: "问题",
            correct: "正确",
            incorrect: "错误",
            notAttempted: "未尝试"
        )
    }
    
    var settings: SettingsStrings {
        SettingsStrings(
            languagePairs: "我的语言",
            notifications: "通知",
            appearance: "美学",
            account: "账户",
            profile: "个人资料",
            addLanguagePair: "添加语言对",
            enableNotifications: "启用通知",
            logout: "登出",
            deleteAllData: "删除所有数据",
            deleteAccount: "删除账户",
            selectLevel: "选择级别",
            selectAppLanguage: "应用界面",
            proFeatures: "高级功能",
            showSimilarWordsToggle: "显示相似词",
            showWordTensesToggle: "显示词的时态",
            nativeLanguage: "母语:",
            selectNativeLanguage: "选择您的母语",
            targetLanguage: "目标语言:",
            selectTargetLanguage: "选择您想学习的语言",
            nativeLanguageDescription: "您的母语是您可以流利地阅读、写作和口语的语言。这是您最舒适的语言。",
            targetLanguageDescription: "您的目标语言是您想要学习和练习的语言。选择您希望提高技能的语言。",
            addPair: "添加配对",
            adding: "添加中...",
            failedToAddLanguagePair: "添加语言对失败。请重试。",
            settingAsDefault: "设置为默认...",
            beginner: "初级",
            intermediate: "中级",
            advanced: "高级",
            currentlyLearning: "正在学习",
            otherLanguages: "其他语言",
            learnNewLanguage: "学习新语言",
            learn: "学习",
            tapToSelectNativeLanguage: "点击选择您的母语",
            neonGreen: "霓虹綠",
            cyanMist: "青色薄雾",
            violetHaze: "紫罗兰薄雾",
            softPink: "柔和粉红",
            pureWhite: "纯白"
        )
    }
    
    var vocabulary: VocabularyStrings {
        VocabularyStrings(
            exploreCategories: "探索类别",
            testYourself: "测试自己",
            slideToStartQuiz: "Slide to start the quiz",
            similarWords: "相似词",
            wordTenses: "词时态",
            wordBreakdown: "词分解",
            tapToSeeBreakdown: "点击单词查看分解",
            tapToHideBreakdown: "点击单词隐藏分解",
            tapWordsToExplore: "点击单词阅读其翻译并探索",
            loading: "加载中...",
            learnTheWord: "学习单词",
            tryFromMemory: "凭记忆尝试",
            adjustingTo: "调整中",
            settingPlace: "设置中",
            settingTime: "设置中",
            generatingVocabulary: "生成中",
            analyzingVocabulary: "分析中",
            analyzingCategories: "分析中",
            analyzingWords: "分析中",
            creatingQuiz: "创建中",
            organizingContent: "整理中",
            to: "到",
            place: "地方",
            time: "时间",
            vocabulary: "词汇",
            your: "你的",
            interested: "感兴趣的",
            categories: "类别",
            words: "单词",
            quiz: "测验",
            content: "内容"
        )
    }
    
    var scene: SceneStrings {
        SceneStrings(
            hi: "你好，",
            learnFromSurroundings: "从周围环境学习",
            learnFromSurroundingsDescription: "捕捉您的环境并从真实世界的语境中学习词汇",
            locianChoosing: "正在选择...",
            chooseLanguages: "选择语言",
            continueWith: "继续使用Locian选择的",
            slideToLearn: "滑动以学习",
            recommended: "推荐",
            intoYourLearningFlow: "进入你的学习流程",
            intoYourLearningFlowDescription: "基于您的学习历史推荐的练习地点",
            customSituations: "您的自定义情况",
            customSituationsDescription: "创建并练习您自己的个性化学习场景",
            max: "最大",
            recentPlacesTitle: "你的常用地点",
            allPlacesTitle: "所有地点",
            recentPlacesEmpty: "生成词汇后将在此显示推荐。",
            showMore: "显示更多",
            showLess: "收起",
            takePhoto: "拍照",
            chooseFromGallery: "从图库选择",
            letLocianChoose: "让Locian选择",
            lociansChoice: "由 Locian",
            cameraTileDescription: "这张照片分析您的环境并显示可学习的时刻。",
            airport: "机场",
            aquarium: "水族馆",
            bakery: "面包店",
            beach: "海滩",
            bookstore: "书店",
            cafe: "咖啡厅",
            cinema: "电影院",
            gym: "健身房",
            hospital: "医院",
            hotel: "酒店",
            home: "家",
            library: "图书馆",
            market: "市场",
            museum: "博物馆",
            office: "办公室",
            park: "公园",
            restaurant: "餐厅",
            shoppingMall: "购物中心",
            stadium: "体育场",
            supermarket: "超市",
            temple: "寺庙",
            travelling: "旅行",
            university: "大学",
            addCustomPlace: "添加自定义地点",
            addPlace: "添加地点",
            enterCustomPlaceName: "输入自定义地点名称（最多30个字符）",
            maximumCustomPlaces: "最多10个自定义地点",
            welcome: "欢迎",
            user: "用户",
            tapToCaptureContext: "点击以捕获您的上下文并开始学习",
            customSection: "自定义",
            examples: "示例：",
            customPlacePlaceholder: "例如：前往办公室",
            exampleTravellingToOffice: "前往办公室",
            exampleTravellingToHome: "回家",
            exampleExploringParis: "探索巴黎",
            exampleVisitingMuseum: "参观博物馆",
            exampleCoffeeShop: "咖啡店",
            characterCount: "字符",
            situationExample1: "在繁忙的咖啡店点咖啡",
            situationExample2: "在新城市问路",
            situationExample3: "在市场购买杂货",
            situationExample4: "预约医生",
            situationExample5: "在酒店办理入住"
        )
    }
    
    var login: LoginStrings {
        LoginStrings(
            login: "登录",
            verify: "验证",
            selectProfession: "选择职业",
            username: "用户名",
            phoneNumber: "电话号码",
            guestLogin: "访客登录",
            guestLoginDescription: ""
        )
    }
    
    var onboarding: OnboardingStrings {
        OnboardingStrings(
            locianHeading: "Locian",
            locianDescription: "从您所在的位置到您需要的每个时态",
            awarenessHeading: "意识",
            awarenessDescription: "AI从您的环境中学习",
            inputsHeading: "输入",
            inputsDescription: "Locian surfaces similar words, word tenses, and full word breakdowns—not just consonant and vowel charts",
            breakdownHeading: "分解",
            breakdownDescription: "Locian将句子分解为时态，提供逐字翻译",
            progressHeading: "Quiz",
            progressDescription: "Preview the rebuild puzzle, adaptive quizzes, and smart shuffle that keep practice fresh",
            readyHeading: "就绪",
            readyDescription: "",
            loginOrRegister: "登录 / 注册",
            pageIndicator: " / 6",
            tapToNavigate: "点击左侧或右侧进行导航",
            selectAppLanguage: "选择应用语言",
            selectLanguageDescription: "此语言将使应用程序用户界面、标题、描述、按钮、名称和所有内容变为所选语言"
        )
    }
    
    var common: CommonStrings {
        CommonStrings(
            cancel: "取消",
            save: "保存",
            done: "完成",
            ok: "确定",
            back: "返回",
            next: "下一步",
            continueText: "继续"
        )
    }
    
    var customPractice: CustomPracticeStrings {
        CustomPracticeStrings(
            custom: "自定义",
            hint: "提示",
            practiceDescription: "点击任何单词将其翻译成您的目标语言。如果需要帮助，请使用提示按钮获取建议。",
            practiceTitle: "练习",
            practiceFollowUp: "继续练习",
            camera: "相机",
            cameraDescription: "Locian将以{native}生成对话，您可以练习转换为{target}。",
            useCamera: "使用相机",
            cameraButtonDescription: "从照片生成时刻",
            typeConversation: "输入对话",
            typeConversationDescription: "Locian将以{native}生成对话，您可以练习转换为{target}。",
            conversationPlaceholder: "例如：在繁忙的咖啡店点咖啡",
            submit: "提交",
            fullCustomText: "完整自定义文本",
            examples: "示例：",
            conversationExample1: "在雨中问路",
            conversationExample2: "深夜购买蔬菜",
            conversationExample3: "在拥挤的办公室工作",
            describeConversation: "描述您希望Locian创建的对话。",
            fullTextPlaceholder: "在此输入完整文本或对话...",
            startCustomPractice: "开始自定义练习"
        )
    }
    
    var progress: ProgressStrings {
        ProgressStrings(
            progress: "进度",
            edit: "编辑",
            current: "当前",
            longest: "最长",
            lastPracticed: "最后练习",
            days: "天",
            addLanguagePairToSeeProgress: "添加语言对以查看您的进度。"
        )
    }
    
    func getString(_ key: String) -> String {
        return key
    }
    
    // Also implement LocalizedStrings protocol
    func getString(for key: StringKey) -> String {
        switch key {
        // Settings
        case .languagePairs: return "我的语言"
        case .notifications: return "通知"
        case .aesthetics: return "美学"
        case .account: return "账户"
        case .appLanguage: return "应用界面"
        
        // Common
        case .login: return "登录 /"
        case .register: return "注册"
        case .settings: return "设置"
        case .home: return "首页"
        case .back: return "返回"
        case .next: return "下一步"
        case .previous: return "上一步"
        case .done: return "完成"
        case .cancel: return "取消"
        case .save: return "保存"
        case .delete: return "删除"
        case .add: return "添加"
        case .remove: return "移除"
        case .edit: return "编辑"
        case .continueText: return "继续"
        
        // Quiz
        case .quizCompleted: return "测验完成！"
        case .sessionCompleted: return "会话完成！"
        case .masteredEnvironment: return "您已掌握您的环境！"
        case .learnMoreAbout: return "了解更多关于"
        case .backToHome: return "返回首页"
        case .tryAgain: return "再试一次"
        case .shuffled: return "已打乱"
        case .check: return "检查"
        
        // Vocabulary
        case .exploreCategories: return "探索类别"
        case .testYourself: return "测试自己"
        case .similarWords: return "相似词："
        case .wordTenses: return "词时态："
        case .tapWordsToExplore: return "点击单词阅读其翻译并探索"
        case .wordBreakdown: return "词分解："
        
        // Scene
        case .analyzingImage: return "正在分析图像..."
        case .imageAnalysisCompleted: return "图像分析完成"
        case .imageSelected: return "已选择图像"
        case .placeNotSelected: return "未选择地点"
        case .chooseLanguages: return "选择语言"
        case .locianChoose: return "Locian选择"
        
        // Settings
        case .enableNotifications: return "启用通知"
        case .thisPlace: return "这个地方"
        case .tapOnAnySection: return "点击上面的任何部分以查看和管理设置"
        case .addNewLanguagePair: return "添加新语言对"
        case .noLanguagePairsAdded: return "尚未添加语言对"
        case .setDefault: return "设为默认"
        case .defaultText: return "默认"
        case .user: return "用户"
        case .noPhone: return "无电话"
        case .signOutFromAccount: return "从您的帐户退出"
        case .removeAllPracticeData: return "删除您的所有练习数据"
        case .permanentlyDeleteAccount: return "永久删除您的帐户和所有数据"
        case .currentLevel: return "当前级别"
        case .selectPhoto: return "选择照片"
        case .camera: return "相机"
        case .photoLibrary: return "照片库"
        case .selectTime: return "选择时间"
        case .hour: return "小时"
        case .minute: return "分钟"
        case .addTime: return "添加时间"
        case .areYouSureLogout: return "您确定要退出吗？"
        case .areYouSureDeleteAccount: return "您确定要删除您的帐户吗？此操作无法撤销。"
        
        // Quiz
        case .goBack: return "返回"
        case .fillInTheBlank: return "填空："
        case .arrangeWordsInOrder: return "按正确顺序排列单词："
        case .tapWordsBelowToAdd: return "点击下面的单词将它们添加到这里"
        case .availableWords: return "可用单词："
        case .correctAnswer: return "正确答案："
        
        // Common
        case .error: return "错误"
        case .ok: return "确定"
        case .close: return "关闭"
        
        // Onboarding
        case .locianHeading: return "Locian"
        case .locianDescription: return "从您所在的位置到您需要的每个时态"
        case .awarenessHeading: return "意识"
        case .awarenessDescription: return "AI从您的环境中学习"
        case .inputsHeading: return "输入"
        case .inputsDescription: return "Locian surfaces similar words, word tenses, and full word breakdowns—not just consonant and vowel charts"
        case .breakdownHeading: return "分解"
        case .breakdownDescription: return "Locian将句子分解为时态，提供逐字翻译"
        case .progressHeading: return "Quiz"
        case .progressDescription: return "Preview the rebuild mini-game, adaptive quizzes, and smart shuffle that keep practice fresh"
        case .readyHeading: return "就绪"
        case .readyDescription: return ""
        
        // Onboarding additional strings
        case .loginOrRegister: return "登录 / 注册"
        case .pageIndicator: return " / 6"
        case .tapToNavigate: return "点击左侧或右侧进行导航"
        case .selectAppLanguage: return "选择应用语言"
        case .selectLanguageDescription: return "此语言将使应用程序用户界面、标题、描述、按钮、名称和所有内容变为所选语言"
        
        // Login
        case .username: return "用户名"
        case .phoneNumber: return "电话号码"
        case .guestLogin: return "访客登录"
        case .guestLoginDescription: return "访客登录用于验证，将允许访客访问所有应用功能。验证后将删除。"
        
        // Professions
        case .student: return "学生"
        case .softwareEngineer: return "软件工程师"
        case .teacher: return "教师"
        case .doctor: return "医生"
        case .artist: return "艺术家"
        case .businessProfessional: return "商业专业人士"
        case .salesOrMarketing: return "销售或营销"
        case .traveler: return "旅行者"
        case .homemaker: return "家庭主妇"
        case .chef: return "厨师"
        case .police: return "警察"
        case .bankEmployee: return "银行员工"
        case .nurse: return "护士"
        case .designer: return "设计师"
        case .engineerManager: return "工程师经理"
        case .photographer: return "摄影师"
        case .contentCreator: return "内容创作者"
        case .other: return "其他"
        
        // Scene Places
        case .lociansChoice: return "Locian的选择"
        case .airport: return "机场"
        case .cafe: return "咖啡厅"
        case .gym: return "健身房"
        case .library: return "图书馆"
        case .office: return "办公室"
        case .park: return "公园"
        case .restaurant: return "餐厅"
        case .shoppingMall: return "购物中心"
        case .travelling: return "旅行"
        case .university: return "大学"
        case .addCustomPlace: return "添加自定义地点"
        case .enterCustomPlaceName: return "输入自定义地点名称（最多30个字符）"
        case .maximumCustomPlaces: return "最多10个自定义地点"
        case .welcome: return "欢迎"
        case .tapToCaptureContext: return "点击以捕获您的上下文并开始学习"
        case .customSection: return "自定义"
        case .examples: return "示例："
        case .customPlacePlaceholder: return "例如：前往办公室"
        case .exampleTravellingToOffice: return "前往办公室"
        case .exampleTravellingToHome: return "回家"
        case .exampleExploringParis: return "探索巴黎"
        case .exampleVisitingMuseum: return "参观博物馆"
        case .exampleCoffeeShop: return "咖啡店"
        case .characterCount: return "字符"
        
        // Settings Modal Strings
        case .nativeLanguage: return "母语:"
        case .selectNativeLanguage: return "选择您的母语"
        case .targetLanguage: return "目标语言:"
        case .selectTargetLanguage: return "选择您想学习的语言"
        case .nativeLanguageDescription: return "您的母语是您可以流利地阅读、写作和口语的语言。这是您最舒适的语言。"
        case .targetLanguageDescription: return "您的目标语言是您想要学习和练习的语言。选择您希望提高技能的语言。"
        case .addPair: return "添加配对"
        case .adding: return "添加中..."
        case .failedToAddLanguagePair: return "添加语言对失败。请重试。"
        case .settingAsDefault: return "设置为默认..."
        case .beginner: return "初级"
        case .intermediate: return "中级"
        case .advanced: return "高级"
        case .currentlyLearning: return "正在学习"
        case .otherLanguages: return "其他语言"
        case .learnNewLanguage: return "学习新语言"
        case .learn: return "学习"
        case .tapToSelectNativeLanguage: return "点击选择您的母语"
        case .neonGreen: return "霓虹綠"
        
        // Theme color names
        case .cyanMist: return "青色薄雾"
        case .violetHaze: return "紫罗兰薄雾"
        case .softPink: return "柔和粉红"
        case .pureWhite: return "纯白"
        
        // Quick Look
        case .quickRecall: return "快速回忆"
        case .startQuickPuzzle: return "开始快速拼图"
        case .stopPuzzle: return "停止拼图"
        
        // Streak
        case .streak: return "连续"
        case .dayStreak: return "天连续"
        case .daysStreak: return "天连续"
        case .editYourStreaks: return "编辑您的连续记录"
        case .editStreaks: return "编辑连续记录"
        case .selectDatesToAddOrRemove: return "选择要添加或删除练习日的日期"
        case .saving: return "保存中..."
        }
    }
}

