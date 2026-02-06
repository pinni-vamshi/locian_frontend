//
//  ChineseStrings.swift
//  locian
//

import Foundation

struct ChineseStrings: AppStrings, LocalizedStrings {
    
    var ui: UIStrings {
        UIStrings(
            camera: "相机",
            gallery: "相册",
            nextUp: "即将进行",
            historyLog: "历史记录",

            moments: "场景",
            pastMoments: "过去场景",
            noHistory: "无历史记录",
            generatingHistory: "正在生成历史记录",
            generatingMoments: "正在生成...",
            analyzingImage: "分析图像...",
            tapNextUpToGenerate: "点击即将进行以生成",
            noUpcomingPlaces: "无即将到来的地点",
            noDetails: "无详细信息",
            callingAI: "Calling AI...",
            preparingLesson: "Preparing your lesson...",

            startLearning: "开始学习",
            continueLearning: "继续学习",
            noPastMoments: "无过去场景",
            useCamera: "使用相机",
            previouslyLearning: "以前学习",
            sunShort: "日",
            monShort: "一",
            tueShort: "二",
            wedShort: "三",
            thuShort: "四",
            friShort: "五",
            satShort: "六",
            login: "登录",
            register: "注册",
            settings: "设置",
            back: "返回",
            done: "完成",
            cancel: "取消",
            save: "保存",
            delete: "删除",
            add: "添加",
            remove: "移除",
            edit: "编辑",
            error: "错误",
            ok: "确定",
            welcomeLabel: "欢迎",
            currentStreak: "当前连续",
            notSet: "未设置",
            learnTab: "学习",
            addTab: "添加",
            progressTab: "进度",
            settingsTab: "设置",
            loading: "加载中...",
            unknownPlace: "未知地点",
            noLanguageAvailable: "无可用语言",
            noInternetConnection: "无网络连接",
            retry: "重试",
            tapToGetMoments: "点击获取当前场景",
            startLearningThisMoment: "从这一刻开始学习",
            daysLabel: "天",
            noNewPlace: "添加新地点",
            addNewPlaceInstruction: "Add a new place to get moments",
            start: "开始",
            typeYourMoment: "在此输入您的瞬间...",
            imagesLabel: "图片",
            routinesLabel: "日常",
            whatAreYouDoing: "你现在在做什么？",
            chooseContext: "选择一个场景开始学习",
            typeHere: "在这里输入",
            nearbyLabel: "附近",
            noNearbyPlaces: "{noNearby}",
            addRoutine: "添加例程",
            tapToSetup: "点击设置",
            tapToStartLearning: "点击开始学习")
    }

    var settings: SettingsStrings {
        SettingsStrings(
            systemLanguage: "应用界面",
            targetLanguages: "目标语言",
            pastLanguagesArchived: "以前学习的语言",
            theme: "主题",
            notifications: "通知",
            account: "账户",
            profile: "个人资料",
            addLanguagePair: "添加语言对",
            logout: "登出",
            deleteAllData: "删除所有数据",
            deleteAccount: "永久删除账户",
            selectLevel: "选择级别",
            proFeatures: "专业功能",
            showSimilarWordsToggle: "显示相似词",
            nativeLanguage: "母 语",
            selectNativeLanguage: "选择母语",
            targetLanguage: "目标语言",
            selectTargetLanguage: "选择目标语言",
            targetLanguageDescription: "您想学习的语言",
            beginner: "初级",
            intermediate: "中级",
            advanced: "高级",
            currentlyLearning: "当前学习中",
            learnNewLanguage: "学习新语言",
            learn: "学习",
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
            otherPlaces: "其他地点",
            speaks: "说",
            neuralEngine: "神经引擎",
            noLanguagePairsAdded: "未添加语言对",
            setDefault: "设为默认",
            defaultText: "默认",
            user: "用户",
            signOutFromAccount: "退出账户",
            permanentlyDeleteAccount: "永久删除账户",
            languageAddedSuccessfully: "语言添加成功",
            failedToAddLanguage: "添加语言失败。请重试。",
            pleaseSelectLanguage: "请选择一种语言",
            systemConfig: "系统 // 配置",
            currentLevel: "当前级别",
            selectPhoto: "选择照片",
            camera: "相机",
            photoLibrary: "照片库",
            selectTime: "选择时间",
            hour: "小时",
            minute: "分钟",
            addTime: "添加时间",
            location: "位置",
            diagnosticBorders: "诊断边界",
            areYouSureLogout: "您确定要退出吗？",
            areYouSureDeleteAccount: "您确定要永久删除您的帐户吗？此操作无法撤消。")
    }

    var login: LoginStrings {
        LoginStrings(
            login: "登录",
            verify: "验证",
            selectProfession: "选择职业",
            selectUserProfession: "SELECT_USER_PROFESSION",
            username: "用户名",
            phoneNumber: "电话号码",
            guestLogin: "访客登录",
            selectProfessionInstruction: "选择您的职业开始",
            showMore: "显示更多",
            showLess: "显示更少",
            forReview: "[待审核]",
            authenticatingUser: "AUTHENTICATING_USER...",
            bySigningInYouAgreeToOur: "By signing in, you agree to our",
            termsOfService: "TERMS_OF_SERVICE",
            privacyPolicy: "PRIVACY_POLICY"
        )
    }

    var onboarding: OnboardingStrings {
        OnboardingStrings(
            locianHeading: "Locian",
            locianDescription: "通过日常生活自然学习语言",
            awarenessHeading: "意识",
            awarenessDescription: "实时注意您周围的单词",
            breakdownHeading: "拆解",
            breakdownDescription: "了解单词的构成",
            progressHeading: "进度",
            progressDescription: "跟踪您的学习之旅",
            readyHeading: "准备好了",
            readyDescription: "现在开始学习",
            loginOrRegister: "登录或注册",
            pageIndicator: "页面",
            selectLanguageDescription: "选择您的首选语言",
            whichLanguageDoYouSpeakComfortably: "您舒适地说哪种语言?",
            chooseTheLanguageYouWantToMaster: "选择您今天想要掌握的语言",
            fromWhereYouStand: "从你站的\n地方",
            toEveryWord: "到",
            everyWord: "每一个词",
            youNeed: "你需要",
            lessonEngine: "课程引擎",
            nodesLive: "节点在线",
            locEngineVersion: "LOC_ENGINE_V2.0.4",
            holoGridActive: "全息网格激活",
            adaCr02: "ADA_CR-02",
            your: "你的",
            places: "地点，",
            lessons: "课程。",
            yourPlaces: "你的地点，",
            yourLessons: " 你的课程。",
            nearbyCafes: "附近的咖啡馆？",
            unlockOrderFlow: " 解锁点单流程",
            modules: "模块",
            activeHubs: "活跃枢纽？",
            synthesizeGym: " 合成健身房",
            vocabulary: "词汇",
            locationOpportunity: "每个地点都成为了学习的机会",
            module03: "模块_03",
            notJustMemorization: "不仅仅是\n死记硬背",
            philosophy: "哲学",
            locianTeaches: "Locian 不仅仅教单词。\nLocian 教你在目标语言中 ",
            think: "思考",
            inTargetLanguage: "。",
            patternBasedLearning: "基于模式的学习",
            patternBasedDesc: "直观地识别语法结构，无需枯燥的规则。",
            situationalIntelligence: "情境智能",
            situationalDesc: "适应您的环境和历史的动态场景。",
            adaptiveDrills: "自适应训练",
            adaptiveDesc: "课程引擎识别您的弱点并重新校准。",
            systemReady: "系统就绪",
            quickSetup: "快速设置",
            levelB2: "等级_B2",
            authorized: "已授权",
            notificationsPermission: "通知",
            notificationsDesc: "获取附近练习机会和连胜提醒的实时更新。",
            microphonePermission: "麦克风",
            microphoneDesc: "对于现实语境中的发音评分和课程互动至关重要。",
            geolocationPermission: "地理位置",
            geolocationDesc: "识别附近的“课程区域”，如咖啡馆或图书馆，进行沉浸式练习。",
            granted: "已授予",
            allow: "允许",
            skip: "跳过",
            letsStart: "开始吧",
            continueText: "继续",
            wordTenses: "时态：",
            similarWords: "相似词：",
            wordBreakdown: "单词拆解：",
            consonant: "辅音",
            vowel: "元音",
            past: "过去",
            present: "现在",
            future: "未来",
            learnWord: "学习")
    }

    var progress: ProgressStrings {
        ProgressStrings(
            progress: "进度",
            current: "当前",
            longest: "最长",
            lastPracticed: "上次练习",
            days: "天",
            addLanguagePairToSeeProgress: "添加语言对以查看您的进度",
            startPracticingMessage: "开始练习以建立您的连续记录",
            consistencyQuote: "坚持是语言学习的关键",
            practiceDateSavingDisabled: "练习日期保存已禁用",
            editYourStreaks: "编辑您的连续记录",
            editStreaks: "编辑连续记录",
            selectDatesToAddOrRemove: "选择要添加或删除的日期",
            saving: "保存中",
            statusOnFire: "状态: 火热",
            youPracticed: "您练习了 ",
            yesterday: " 昨天.",
            checkInNow: "立即打卡",
            nextGoal: "下个目标",
            reward: "奖励",
            historyLogProgress: "历史记录",
            streakStatus: "连胜状态",
            streakLog: "连胜记录",
            consistency: "一致性",
            consistencyHigh: "您的活动记录显示出很高的参与度。",
            consistencyMedium: "您正在建立良好的势头。",
            consistencyLow: "一致性是关键。继续努力。",
            reachMilestone: "努力达到 %d 天！",
            nextMilestone: "下一个里程碑",
            actionRequired: "需要行动",
            logActivity: "记录活动",
            maintainStreak: "Maintain Streak",
            manualEntry: "Manual Entry",
            longestStreakLabel: "最长连胜",
            streakData: "连续数据",
            activeLabel: "活跃",
            missedLabel: "错过",
            saveChanges: "保存更改",
            discardChanges: "放弃更改",
            editLabel: "编辑",
            // Advanced Stats
            skillBalance: "技能平衡",
            fluencyVelocity: "流利速度",
            vocabVault: "单词库",
            chronotype: "昼夜节律型",
            activityDistribution: "活动分布 (24小时)",
            studiedTime: "学习时间",
            currentLabel: "当前",
            streakLabel: "打卡",
            longestLabel: "最长",
            earlyBird: "早起鸟",
            earlyBirdDesc: "早晨最为活跃",
            dayWalker: "昼行者",
            dayWalkerDesc: "下午最为活跃",
            nightOwl: "夜猫子",
            nightOwlDesc: "入夜后最为活跃",
            timeMastery: "时间掌控",
            wordsMastered: "Words Mastered",
            patternsMastered: "Patterns Active",
            avgResponseTime: "Avg Response Time",
            patternGalaxy: "PATTERN GALAXY")
    }

    var quiz: QuizStrings {
        QuizStrings(            loading: "加载中...",
            adaptiveQuiz: "自适应测验",
            adaptiveQuizDescription: "我们先提示错误翻译，然后显示正确单词。",
            wordCheck: "单词检查",
            wordCheckDescription: "拼图块首先被打乱，然后归位以确认正确单词。",
            wordCheckExamplePrompt: "点击字母按正确顺序排列单词。",
            quizPrompt: "为单词选择正确的翻译。",
            answerConfirmation: "您拼出了正确的单词！",
            tryAgain: "哎呀！再试一次。")
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
        case .addRoutine: return ui.addRoutine
        case .tapToSetup: return ui.tapToSetup
        case .tapToStartLearning: return ui.tapToStartLearning
        }
    }
}
