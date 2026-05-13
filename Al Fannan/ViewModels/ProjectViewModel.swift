import SwiftUI
import Observation

@Observable
class ProjectViewModel {
    var projects: [Project] = []
    var recentProjects: [Project] = []
    var currentProject: Project?
    var isLoading = false
    var searchText = ""
    private let storageService = ProjectStorageService()
    
    init() {
        loadSavedProjects()
    }
    
    /// Load all previously saved projects from disk
    func loadSavedProjects() {
        isLoading = true
        let savedProjects = storageService.loadProjects()
        
        var loaded: [Project] = []
        for saved in savedProjects {
            var project = Project(name: saved.name, nameAr: saved.nameAr,
                                  canvasWidth: saved.canvasWidth, canvasHeight: saved.canvasHeight)
            project.id = saved.id
            project.backgroundColor = saved.backgroundColor.hex
            project.elements = saved.elements.map { CanvasElement.fromSaved($0) }
            project.createdAt = saved.createdAt
            project.updatedAt = saved.modifiedAt
            loaded.append(project)
        }
        
        projects = loaded
        recentProjects = Array(loaded.prefix(10))
        isLoading = false
    }
    
    func createNewProject(preset: CanvasPreset) -> Project {
        let project = Project(name: preset.name, nameAr: preset.nameAr,
                              canvasWidth: preset.width, canvasHeight: preset.height)
        projects.insert(project, at: 0)
        recentProjects.insert(project, at: 0)
        currentProject = project
        return project
    }
    
    func deleteProject(_ id: UUID) {
        projects.removeAll(where: { $0.id == id })
        recentProjects.removeAll(where: { $0.id == id })
        try? storageService.deleteProject(id)
    }
    
    func loadThumbnail(for projectId: UUID) -> UIImage? {
        storageService.loadThumbnail(for: projectId)
    }
    
    var filteredProjects: [Project] {
        if searchText.isEmpty { return projects }
        return projects.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.nameAr.contains(searchText)
        }
    }
}
