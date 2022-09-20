#ifndef GLACIERWINDOWMODEL_H
#define GLACIERWINDOWMODEL_H
#include <QDebug>
#include <lipstickcompositorwindow.h>
#include <windowmodel.h>
class LipstickCompositorWindow;
class QWaylandSurfaceItem;

class Q_DECL_EXPORT GlacierWindowModel : public WindowModel {
    Q_OBJECT
public:
    explicit GlacierWindowModel();
    bool approveWindow(LipstickCompositorWindow* window);
    Q_INVOKABLE int getWindowIdForTitle(QString title);
    Q_INVOKABLE void removeWindowForTitle(QString title);

private:
    QHash<QString, int> m_titles;
};

#endif // GLACIERWINDOWMODEL_H
