#ifndef PROGRAMSETTINGS_H
#define PROGRAMSETTINGS_H

#include <QObject>
#include <QJsonDocument>
#include <QJsonObject>

/*
 * Save/restore program settings
 */

class ProgramSettings : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int todOffset READ todOffset WRITE setTodOffset NOTIFY todOffsetChanged)
    Q_PROPERTY(int screenOffsetX READ getScreenOffsetX WRITE setScreenoffsetX NOTIFY screenOffsetXChanged)
    Q_PROPERTY(int screenOffsetY READ getScreenOffsetY WRITE setScreenoffsetY NOTIFY screenOffsetYChanged)
    Q_PROPERTY(bool settingsInitialized READ areSettingsInitialized WRITE intializeSettings NOTIFY initializationChanged)
public:
    explicit ProgramSettings(QObject *parent = 0);

    void loadSettings(void);
    void saveSettings(void);
    void initializeSettingsToDefaults(void);

    void setTodOffset(int newOffset);
    int todOffset();
    void setScreenoffsetX(int OffsetX);
    void setScreenoffsetY(int OffsetY);
    int getScreenOffsetX();
    int getScreenOffsetY();
    bool areSettingsInitialized();
    void intializeSettings(bool status);
signals:
    void todOffsetChanged();
    void screenOffsetXChanged();
    void screenOffsetYChanged();
    void initializationChanged();

public slots:
private:
    int m_todOffset;
    int m_screenXOffset;
    int m_screenYOffset;
    bool m_settingsInitialized;

    void loadSettingsFromJsonObject(const QJsonObject &settings);
    void storeSettingsToJsonObject(QJsonObject &settings) const;
};

#endif // PROGRAMSETTINGS_H