#include <iostream>
#include "programSettings.h"
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>

using namespace std;

// Defaults here...
const int defaultTodOffset = 0;
const int defaultScreenXOffset = 60;
const int defaultScreenYOffset = 25;

ProgramSettings::ProgramSettings(QObject *parent) : QObject(parent)
{
    initializeSettingsToDefaults();
}

void ProgramSettings::loadSettings(void)
{
    QFile loadFile(QStringLiteral("settings.json"));

    if (!loadFile.open(QIODevice::ReadOnly)) {
        qWarning("Couldn't open save file, initializing...");
        return;
    }

    m_settingsInitialized = true;

    QByteArray saveData = loadFile.readAll();

    QJsonDocument loadDoc(QJsonDocument::fromJson(saveData));

    loadSettingsFromJsonObject(loadDoc.object());
}

void ProgramSettings::saveSettings(void)
{
    QFile saveFile(QStringLiteral("settings.json"));

    if (!saveFile.open(QIODevice::WriteOnly)) {
        qWarning("Couldn't open save file.");
        return;
    }

    QJsonObject jsonSettings;
    storeSettingsToJsonObject(jsonSettings);
    QJsonDocument saveDoc(jsonSettings);
    saveFile.write(saveDoc.toJson());

    m_settingsInitialized = true;
}

void ProgramSettings::loadSettingsFromJsonObject(const QJsonObject &settings)
{
    m_todOffset = (settings.contains("todOffset")) ? settings["todOffset"].toInt() : defaultTodOffset;
    m_screenXOffset = (settings.contains("screenOffsetX")) ? settings["screenOffsetX"].toInt() : defaultScreenXOffset;
    m_screenYOffset = (settings.contains("screenOffsetY")) ? settings["screenOffsetY"].toInt() : defaultScreenYOffset;
}

void ProgramSettings::storeSettingsToJsonObject(QJsonObject &settings) const
{
    settings["todOffset"] = m_todOffset;
    settings["screenOffsetX"] = m_screenXOffset;
    settings["screenOffsetY"] = m_screenYOffset;
}

void ProgramSettings::initializeSettingsToDefaults(void)
{
    // initialize all settings here
    m_todOffset = defaultTodOffset;
    m_screenXOffset = defaultScreenXOffset;
    m_screenYOffset = defaultScreenYOffset;
    m_settingsInitialized = false;
}

void ProgramSettings::setTodOffset(int newOffset)
{
    cout << "Setting time of day offset to " << newOffset << endl;
    if (newOffset != m_todOffset) {
        m_todOffset = newOffset;
        emit todOffsetChanged();
        saveSettings();
    }
}

int ProgramSettings::todOffset()
{\
    return m_todOffset;
}

void ProgramSettings::setScreenoffsetX(int OffsetX)
{
    cout << "Setting screen offset X to " << OffsetX << endl;
    if (OffsetX != m_screenXOffset) {
        m_screenXOffset = OffsetX;
        emit screenOffsetXChanged();
        saveSettings();
    }
}

int ProgramSettings::getScreenOffsetX()
{
    return m_screenXOffset;
}

void ProgramSettings::setScreenoffsetY(int OffsetY)
{
    cout << "Setting screen offset Y to " << OffsetY << endl;
    if (OffsetY != m_screenYOffset) {
        m_screenYOffset = OffsetY;
        emit screenOffsetYChanged();
        saveSettings();
    }
}

int ProgramSettings::getScreenOffsetY()
{
    return m_screenYOffset;
}

bool ProgramSettings::areSettingsInitialized()
{
    return m_settingsInitialized;
}
void ProgramSettings::intializeSettings(bool status)
{
    m_settingsInitialized = status;
    emit screenOffsetYChanged();
}