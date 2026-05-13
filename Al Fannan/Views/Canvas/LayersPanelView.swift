import SwiftUI

struct LayersPanelView: View {
    @Bindable var viewModel: CanvasViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if viewModel.elements.isEmpty {
                    EmptyStateView(icon: "square.3.layers.3d",
                                   title: "No Layers",
                                   message: "Add elements to see them here")
                    .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(Array(viewModel.sortedElements.reversed().enumerated()), id: \.element.id) { index, element in
                            layerRow(element)
                                .listRowBackground(
                                    viewModel.selectedElementIds.contains(element.id) ?
                                    Color.red.opacity(0.1) : Color.clear
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(viewModel.selectedElementIds.contains(element.id) ? Color.red : Color.clear, lineWidth: 1)
                                )
                        }
                        .onDelete { indexSet in
                            // Delete layers by index
                            let reversed = viewModel.sortedElements.reversed()
                            let items = Array(reversed)
                            for index in indexSet {
                                if index < items.count {
                                    viewModel.removeElement(items[index].id)
                                }
                            }
                        }
                        .onMove { source, destination in
                            // Map from reversed sorted order to actual zIndex changes
                            var items = Array(viewModel.sortedElements.reversed())
                            items.move(fromOffsets: source, toOffset: destination)
                            // Reassign zIndex based on new order (reversed because top layer = highest zIndex)
                            for (i, item) in items.enumerated() {
                                let newZ = items.count - 1 - i
                                viewModel.updateElement(item.id) { el in
                                    el.zIndex = newZ
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .environment(\.editMode, .constant(.active))
                }
            }
            .background(DS.Colors.bgPrimary)
            .navigationTitle("Layers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(DS.Colors.primary)
                }
            }
        }
    }
    
    private func layerRow(_ element: CanvasElement) -> some View {
        let isSelected = viewModel.selectedElementIds.contains(element.id)
        
        return HStack(spacing: DS.Spacing.sm) {
            // Selection toggle
            Button {
                viewModel.toggleSelection(element.id)
                HapticManager.selection()
            } label: {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18))
                    .foregroundColor(isSelected ? .red : DS.Colors.textTertiary)
                    .frame(width: 32, height: 32)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            // Visibility toggle
            Button {
                viewModel.toggleVisibility(element.id)
                HapticManager.selection()
            } label: {
                Image(systemName: element.isVisible ? "eye.fill" : "eye.slash")
                    .font(.system(size: 14))
                    .foregroundColor(element.isVisible ? DS.Colors.primary : DS.Colors.textTertiary)
                    .frame(width: 32, height: 32)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            // Type icon
            Image(systemName: element.type.icon)
                .font(.system(size: 16))
                .foregroundColor(DS.Colors.textSecondary)
                .frame(width: 24)
            
            // Name
            VStack(alignment: .leading, spacing: 2) {
                Text(element.name)
                    .font(DS.Typography.captionSmall)
                    .foregroundColor(DS.Colors.textPrimary)
                if let text = element.text {
                    Text(text)
                        .font(.system(size: 10))
                        .foregroundColor(DS.Colors.textTertiary)
                        .lineLimit(1)
                }
            }
            .onTapGesture {
                viewModel.selectElement(element.id)
                HapticManager.softTap()
            }
            
            Spacer()
            
            // Lock toggle
            Button {
                viewModel.toggleLock(element.id)
                HapticManager.selection()
            } label: {
                Image(systemName: element.isLocked ? "lock.fill" : "lock.open")
                    .font(.system(size: 12))
                    .foregroundColor(element.isLocked ? DS.Colors.warning : DS.Colors.textTertiary)
                    .frame(width: 32, height: 32)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            // Delete
            Button {
                viewModel.removeElement(element.id)
                HapticManager.softTap()
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 12))
                    .foregroundColor(DS.Colors.error.opacity(0.7))
                    .frame(width: 32, height: 32)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, DS.Spacing.xs)
    }
}
