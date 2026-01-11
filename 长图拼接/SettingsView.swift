//
//  SettingsView.swift
//  长图拼接
//
//  Created by Mercury on 2026/1/11.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        PrivacyPolicyView()
                    } label: {
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
                    }
                    
                    NavigationLink {
                        TermsOfServiceView()
                    } label: {
                        Label("Terms of Service", systemImage: "doc.text.fill")
                    }
                } header: {
                    Text("Legal")
                }
                
                Section {
                    Button {
                        showingResetAlert = true
                    } label: {
                        Label("Show Welcome Guide", systemImage: "book.fill")
                    }
                } header: {
                    Text("Help")
                }
                
                Section {
                    HStack {
                        Label("Version", systemImage: "info.circle.fill")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.medium)
                }
            }
            .alert("Show Welcome Guide?", isPresented: $showingResetAlert) {
                Button("Show") {
                    UserDefaults.standard.set(false, forKey: "hasSeenOnboarding")
                    dismiss()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("The welcome guide will appear next time you open the app.")
            }
        }
    }
}

// MARK: - Privacy Policy
struct PrivacyPolicyView: View {
    @Environment(\.locale) var locale
    
    private var isChinese: Bool {
        locale.language.languageCode?.identifier == "zh"
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(isChinese ? "最后更新：2026年1月11日" : "Last updated: January 11, 2026")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                if isChinese {
                    chineseContent
                } else {
                    englishContent
                }
            }
            .padding()
        }
        .navigationTitle(isChinese ? "隐私政策" : "Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var englishContent: some View {
        Group {
            PolicySection(title: "Introduction") {
                Text("LongPic (\"we\", \"our\", or \"us\") respects your privacy and is committed to protecting your personal data. This Privacy Policy explains how we handle your information when you use our mobile application.")
            }
            
            PolicySection(title: "Information We Collect") {
                Text("We do not collect, store, or transmit any personal information. All image processing is performed locally on your device.")
                Text("• Photos: We access your photo library only when you explicitly select images to stitch. These images are processed entirely on your device and are never uploaded to any server.")
                Text("• No Analytics: We do not use any analytics or tracking tools.")
                Text("• No Account Required: Our app does not require you to create an account or provide any personal information.")
            }
            
            PolicySection(title: "Photo Library Access") {
                Text("Our app requires access to your photo library to:")
                Text("• Allow you to select photos for stitching")
                Text("• Save the stitched images back to your library")
                Text("This access is used solely for the core functionality of the app. Your photos never leave your device.")
            }
            
            PolicySection(title: "Data Storage") {
                Text("All data processing occurs locally on your device. We do not have servers that store your images or any other personal data. When you close the app, any temporarily loaded images are cleared from memory.")
            }
            
            PolicySection(title: "Third-Party Services") {
                Text("Our app does not integrate with any third-party services, advertising networks, or analytics platforms. Your data stays on your device.")
            }
            
            PolicySection(title: "Children's Privacy") {
                Text("Our app does not knowingly collect any information from children under 13. The app is a simple utility tool that does not require any personal information to function.")
            }
            
            PolicySection(title: "Changes to This Policy") {
                Text("We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the \"Last updated\" date.")
            }
            
            PolicySection(title: "Contact Us") {
                Text("If you have any questions about this Privacy Policy, please contact us at:")
                Text("support@example.com")
                    .foregroundStyle(.blue)
            }
        }
    }
    
    private var chineseContent: some View {
        Group {
            PolicySection(title: "简介") {
                Text("长图拼接（以下简称"我们"）尊重您的隐私，并致力于保护您的个人数据。本隐私政策说明了我们在您使用本应用时如何处理您的信息。")
            }
            
            PolicySection(title: "我们收集的信息") {
                Text("我们不收集、存储或传输任何个人信息。所有图片处理均在您的设备本地完成。")
                Text("• 照片：仅当您明确选择要拼接的图片时，我们才会访问您的相册。这些图片完全在您的设备上处理，绝不会上传到任何服务器。")
                Text("• 无数据分析：我们不使用任何分析或追踪工具。")
                Text("• 无需账户：本应用不需要您创建账户或提供任何个人信息。")
            }
            
            PolicySection(title: "相册访问权限") {
                Text("本应用需要访问您的相册以：")
                Text("• 允许您选择要拼接的照片")
                Text("• 将拼接后的图片保存到您的相册")
                Text("此权限仅用于应用的核心功能。您的照片绝不会离开您的设备。")
            }
            
            PolicySection(title: "数据存储") {
                Text("所有数据处理均在您的设备本地进行。我们没有存储您的图片或任何其他个人数据的服务器。当您关闭应用时，任何临时加载的图片都会从内存中清除。")
            }
            
            PolicySection(title: "第三方服务") {
                Text("本应用不与任何第三方服务、广告网络或分析平台集成。您的数据始终保留在您的设备上。")
            }
            
            PolicySection(title: "儿童隐私") {
                Text("本应用不会故意收集13岁以下儿童的任何信息。本应用是一个简单的工具类应用，不需要任何个人信息即可使用。")
            }
            
            PolicySection(title: "政策变更") {
                Text("我们可能会不时更新本隐私政策。我们将通过在此页面发布新的隐私政策并更新"最后更新"日期来通知您任何变更。")
            }
            
            PolicySection(title: "联系我们") {
                Text("如果您对本隐私政策有任何疑问，请通过以下方式联系我们：")
                Text("support@example.com")
                    .foregroundStyle(.blue)
            }
        }
    }
}


// MARK: - Terms of Service
struct TermsOfServiceView: View {
    @Environment(\.locale) var locale
    
    private var isChinese: Bool {
        locale.language.languageCode?.identifier == "zh"
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(isChinese ? "最后更新：2026年1月11日" : "Last updated: January 11, 2026")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                if isChinese {
                    chineseContent
                } else {
                    englishContent
                }
            }
            .padding()
        }
        .navigationTitle(isChinese ? "用户协议" : "Terms of Service")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var englishContent: some View {
        Group {
            PolicySection(title: "Acceptance of Terms") {
                Text("By downloading, installing, or using LongPic (\"the App\"), you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the App.")
            }
            
            PolicySection(title: "Description of Service") {
                Text("LongPic is a mobile application that allows users to combine multiple images into a single vertical long image. The service is provided \"as is\" and processes all images locally on your device.")
            }
            
            PolicySection(title: "User Responsibilities") {
                Text("You agree to:")
                Text("• Use the App only for lawful purposes")
                Text("• Not use the App to process images that infringe on others' intellectual property rights")
                Text("• Not use the App to create content that is illegal, harmful, or offensive")
                Text("• Take responsibility for all images you process using the App")
            }
            
            PolicySection(title: "Intellectual Property") {
                Text("The App and its original content, features, and functionality are owned by us and are protected by international copyright, trademark, and other intellectual property laws.")
                Text("You retain all rights to the images you process using the App. We do not claim any ownership over your content.")
            }
            
            PolicySection(title: "Disclaimer of Warranties") {
                Text("The App is provided on an \"AS IS\" and \"AS AVAILABLE\" basis without warranties of any kind, either express or implied, including but not limited to:")
                Text("• Merchantability")
                Text("• Fitness for a particular purpose")
                Text("• Non-infringement")
                Text("We do not warrant that the App will be uninterrupted, error-free, or free of viruses or other harmful components.")
            }
            
            PolicySection(title: "Limitation of Liability") {
                Text("To the maximum extent permitted by law, we shall not be liable for any indirect, incidental, special, consequential, or punitive damages, including but not limited to loss of data, profits, or goodwill, arising out of or in connection with your use of the App.")
            }
            
            PolicySection(title: "Changes to Terms") {
                Text("We reserve the right to modify these Terms of Service at any time. We will provide notice of significant changes by updating the \"Last updated\" date. Your continued use of the App after such modifications constitutes your acceptance of the updated terms.")
            }
            
            PolicySection(title: "Governing Law") {
                Text("These Terms shall be governed by and construed in accordance with the laws of the jurisdiction in which we operate, without regard to its conflict of law provisions.")
            }
            
            PolicySection(title: "Contact Us") {
                Text("If you have any questions about these Terms of Service, please contact us at:")
                Text("support@example.com")
                    .foregroundStyle(.blue)
            }
        }
    }
    
    private var chineseContent: some View {
        Group {
            PolicySection(title: "条款接受") {
                Text("下载、安装或使用长图拼接（以下简称"本应用"）即表示您同意受本用户协议的约束。如果您不同意这些条款，请勿使用本应用。")
            }
            
            PolicySection(title: "服务说明") {
                Text("长图拼接是一款移动应用程序，允许用户将多张图片合并成一张垂直长图。本服务按"原样"提供，所有图片处理均在您的设备本地完成。")
            }
            
            PolicySection(title: "用户责任") {
                Text("您同意：")
                Text("• 仅将本应用用于合法目的")
                Text("• 不使用本应用处理侵犯他人知识产权的图片")
                Text("• 不使用本应用创建非法、有害或冒犯性的内容")
                Text("• 对您使用本应用处理的所有图片负责")
            }
            
            PolicySection(title: "知识产权") {
                Text("本应用及其原创内容、功能和特性归我们所有，受国际版权、商标和其他知识产权法律保护。")
                Text("您保留使用本应用处理的图片的所有权利。我们不对您的内容主张任何所有权。")
            }
            
            PolicySection(title: "免责声明") {
                Text("本应用按"原样"和"可用"的基础提供，不提供任何明示或暗示的保证，包括但不限于：")
                Text("• 适销性")
                Text("• 特定用途的适用性")
                Text("• 不侵权")
                Text("我们不保证本应用将不间断、无错误或不含病毒或其他有害组件。")
            }
            
            PolicySection(title: "责任限制") {
                Text("在法律允许的最大范围内，我们不对任何间接、附带、特殊、后果性或惩罚性损害承担责任，包括但不限于因您使用本应用而产生的数据丢失、利润损失或商誉损失。")
            }
            
            PolicySection(title: "条款变更") {
                Text("我们保留随时修改本用户协议的权利。我们将通过更新"最后更新"日期来通知重大变更。您在此类修改后继续使用本应用即表示您接受更新后的条款。")
            }
            
            PolicySection(title: "适用法律") {
                Text("本条款应受我们运营所在司法管辖区的法律管辖并据其解释，不考虑其法律冲突条款。")
            }
            
            PolicySection(title: "联系我们") {
                Text("如果您对本用户协议有任何疑问，请通过以下方式联系我们：")
                Text("support@example.com")
                    .foregroundStyle(.blue)
            }
        }
    }
}

// MARK: - Policy Section Component
struct PolicySection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 6) {
                content
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    SettingsView()
}
