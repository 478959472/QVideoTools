#include "ffmpegwrapper.h"
#include <QDebug>

FFmpegWrapper::FFmpegWrapper(QObject *parent)
    : QObject{parent}, m_process(new QProcess(this)),m_output(new QString())
{
    connect(m_process, &QProcess::readyReadStandardOutput, this, &FFmpegWrapper::onReadyReadStandardOutput);
//    connect(m_process, &QProcess::readyReadStandardError, this, &FFmpegWrapper::onReadyReadStandardOutput);

    connect(m_process, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished), this, &FFmpegWrapper::onFinished);
}


void FFmpegWrapper::executeFFmpegCommand(const QString &command) {
    qDebug() << "执行命令：" << command;
    QStringList arguments = command.split(" ", Qt::SkipEmptyParts);
    QString program = arguments.takeFirst();
    m_process->start(program, arguments);
    if (!m_process->waitForStarted()) {
        qDebug() << "Error: Unable to start process.";
        return;
    }
    m_process->waitForFinished(-1);
}

qint64 FFmpegWrapper::getFileSize(const QString &filePath)
{
    qDebug() << "获取文件大小，文件路径：" << filePath;
    QFileInfo fileInfo(filePath);
    qint64 fileSize = fileInfo.size();
    qDebug() << "文件大小:" << fileSize;
    return fileSize;
}

void FFmpegWrapper::onReadyReadStandardOutput()
{
    QString output = m_process->readAllStandardOutput();
    m_output->append(output);

}


void FFmpegWrapper::onFinished(int exitCode, QProcess::ExitStatus exitStatus) {
    qDebug() << "执行完成：" << *m_output;
    if (exitStatus == QProcess::NormalExit) {
        qDebug() << "FFmpeg process finished successfully with exit code" << exitCode;
        emit outputReceived(*m_output);
    } else {
        qDebug() << "FFmpeg process failed with exit code" << exitCode;
    }
}
