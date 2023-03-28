#ifndef FFMPEGWRAPPER_H
#define FFMPEGWRAPPER_H
#include <QObject>
#include <QProcess>
#include <QFileInfo>

class FFmpegWrapper : public QObject
{
    Q_OBJECT
public:
    explicit FFmpegWrapper(QObject *parent = nullptr);
    Q_INVOKABLE void executeFFmpegCommand(const QString &command);
    Q_INVOKABLE qint64 getFileSize(const QString &filePath);

private:
    QProcess *m_process;
    QString *m_output;

signals:
    void outputReceived(const QString &output);

private slots:
    void onReadyReadStandardOutput();
    void onFinished(int exitCode, QProcess::ExitStatus exitStatus);

};

#endif // FFMPEGWRAPPER_H
