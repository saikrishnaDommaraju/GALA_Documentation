Imports EModelView

Public Class eDwHost
    Private WithEvents ocx As EModelViewControl = Nothing

    Protected Overrides Sub AttachInterfaces()
        MyBase.AttachInterfaces()


        Try
#If PLATFORM = "x64" Then
            Me.ocx = MyBase.GetOcx()
#ElseIf PLATFORM = "AnyCPU" Then
            ' Check 32/64 bit at runtime ...
            If IntPtr.Size = 8 Then
                Me.ocx = MyBase.GetOcx()
            End If
#Else
            "Forced compiler error! This code can never work in 32-bit processes since it depends on an ActiveX contronl which is only available in 64-bit."
#End If
            
        Catch ex As Exception
            MessageBox.Show(ex.Message & vbCrLf & vbCrLf & ex.StackTrace, "Exception loading eModelViewControl")
        End Try
    End Sub

    Public Overloads Function GetOcx() As EModelViewControl
        Return MyBase.GetOcx()
    End Function

End Class
