import SwiftUI

struct MyProjectsView: View {
    @State private var storage = ProjectStorageService()
    @State private var projects: [SavedProject] = []
    @State private var searchText = ""
    @State private var showDeleteConfirm = false
    @State private var projectToDelete: SavedProject?
    @State private var animateList = false
    @Environment(\.dismiss) private var dismiss
    
    var filteredProjects: [SavedProject] {
        if searchText.isEmpty { return projects }
        return projects.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.nameAr.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                DS.Colors.bgPrimary.ignoresSafeArea()
                
                if projects.isEmpty {
                    emptyState
                } else {
                    projectsList
                }
            }
            .navigationTitle("My Projects")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search projects...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(DS.Colors.textTertiary)
                    }
                }
            }
            .onAppear {
                projects = storage.loadProjects()
                withAnimation(AnimationPreset.springSmooth.delay(0.2)) {
                    animateList = true
                }
            }
            .confirmationDialog(
                "Delete Project?",
                isPresented: $showDeleteConfirm,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    if let project = projectToDelete {
                        deleteProject(project)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: DS.Spacing.lg) {
            ZStack {
                Circle()
                    .fill(DS.Colors.primary.opacity(0.08))
                    .frame(width: 120, height: 120)
                Image(systemName: "folder.badge.plus")
                    .font(.system(size: 44))
                    .foregroundColor(DS.Colors.primary)
            }
            .floating()
            
            VStack(spacing: DS.Spacing.xs) {
                Text("No Saved Projects")
                    .font(DS.Typography.title)
                    .foregroundColor(DS.Colors.textPrimary)
                Text("لا توجد مشاريع محفوظة")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(DS.Colors.primary)
                Text("Your saved designs will appear here")
                    .font(DS.Typography.caption)
                    .foregroundColor(DS.Colors.textTertiary)
            }
        }
    }
    
    private var projectsList: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: DS.Spacing.sm),
                GridItem(.flexible(), spacing: DS.Spacing.sm),
            ], spacing: DS.Spacing.sm) {
                ForEach(Array(filteredProjects.enumerated()), id: \.element.id) { index, project in
                    projectCard(project, index: index)
                }
            }
            .padding(DS.Spacing.md)
        }
    }
    
    private func projectCard(_ project: SavedProject, index: Int) -> some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
            // Thumbnail
            ZStack {
                RoundedRectangle(cornerRadius: DS.Radius.md)
                    .fill(
                        LinearGradient(
                            colors: [DS.Colors.bgElevated, DS.Colors.bgTertiary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .aspectRatio(project.canvasWidth / project.canvasHeight, contentMode: .fit)
                
                if let thumbnail = storage.loadThumbnail(for: project.id) {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                } else {
                    VStack(spacing: 6) {
                        Image(systemName: "paintbrush.pointed")
                            .font(.system(size: 28))
                            .foregroundColor(DS.Colors.primary.opacity(0.5))
                        if !project.nameAr.isEmpty {
                            Text(project.nameAr)
                                .font(.system(size: 12))
                                .foregroundColor(DS.Colors.textTertiary)
                        }
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.md)
                    .stroke(DS.Colors.surfaceBorder, lineWidth: 1)
            )
            
            // Info
            VStack(alignment: .leading, spacing: 2) {
                Text(project.name)
                    .font(DS.Typography.captionSmall)
                    .foregroundColor(DS.Colors.textPrimary)
                    .lineLimit(1)
                HStack(spacing: 4) {
                    Text("\(Int(project.canvasWidth))×\(Int(project.canvasHeight))")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(DS.Colors.textTertiary)
                    Spacer()
                    Text(project.modifiedAt.relativeString)
                        .font(.system(size: 9))
                        .foregroundColor(DS.Colors.textTertiary)
                }
            }
        }
        .contextMenu {
            Button(role: .destructive) {
                projectToDelete = project
                showDeleteConfirm = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
            
            Button {
                // Duplicate logic
            } label: {
                Label("Duplicate", systemImage: "doc.on.doc")
            }
        }
        .opacity(animateList ? 1 : 0)
        .offset(y: animateList ? 0 : 20)
        .animation(
            AnimationPreset.springSmooth.delay(Double(index) * 0.05),
            value: animateList
        )
    }
    
    private func deleteProject(_ project: SavedProject) {
        withAnimation {
            try? storage.deleteProject(project.id)
            projects.removeAll(where: { $0.id == project.id })
        }
        HapticManager.notification(.warning)
    }
}
