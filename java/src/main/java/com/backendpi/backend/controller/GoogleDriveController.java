package com.backendpi.backend.controller;

import com.backendpi.backend.service.GoogleDriveService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class GoogleDriveController {

    private final GoogleDriveService googleDriveService;

    public GoogleDriveController(GoogleDriveService googleDriveService) {
        this.googleDriveService = googleDriveService;
    }

    @GetMapping("/google/auth")
    public String googleAuth() {

        return """
                <html>
                    <body>
                        <h2>Autorizar Google Drive</h2>
                        <a href="%s">Clique aqui para autorizar</a>
                    </body>
                </html>
                """.formatted(
                googleDriveService.getAuthorizationUrl()
        );
    }

    @GetMapping("/google/callback")
    public String googleCallback(
            @RequestParam("code") String code
    ) throws Exception {

        String refreshToken =
                googleDriveService.getRefreshToken(code);

        return """
                <html>
                    <body>
                        <h2>Autorização concluída!</h2>
                        <p>Seu Refresh Token:</p>
                        <textarea rows="10" cols="100">%s</textarea>
                        <p>Copie esse valor para o Render.</p>
                    </body>
                </html>
                """.formatted(refreshToken);
    }
}