package com.backendpi.backend.service;

import com.google.api.client.googleapis.auth.oauth2.GoogleAuthorizationCodeFlow;
import com.google.api.client.googleapis.auth.oauth2.GoogleClientSecrets;
import com.google.api.client.googleapis.auth.oauth2.GoogleTokenResponse;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import com.google.api.client.auth.oauth2.Credential;
import org.springframework.stereotype.Service;

import java.util.Arrays;

@Service
public class GoogleDriveService {

    private static final GsonFactory JSON_FACTORY = GsonFactory.getDefaultInstance();
    private static final NetHttpTransport HTTP_TRANSPORT = new NetHttpTransport();

    private final String clientId =
            System.getenv("GOOGLE_CLIENT_ID");

    private final String clientSecret =
            System.getenv("GOOGLE_CLIENT_SECRET");

    private final String redirectUri =
            "https://projeto-integrador-m4jn.onrender.com/google/callback";

    public String getAuthorizationUrl() {

        GoogleClientSecrets.Details details =
                new GoogleClientSecrets.Details()
                        .setClientId(clientId)
                        .setClientSecret(clientSecret);

        GoogleClientSecrets secrets =
                new GoogleClientSecrets().setWeb(details);

        GoogleAuthorizationCodeFlow flow =
                new GoogleAuthorizationCodeFlow.Builder(
                        HTTP_TRANSPORT,
                        JSON_FACTORY,
                        secrets,
                        Arrays.asList(
                                "https://www.googleapis.com/auth/drive.file"
                        )
                )
                .setAccessType("offline")
                .build();

        return flow.newAuthorizationUrl()
                .setRedirectUri(redirectUri)
                .setAccessType("offline")
                .setApprovalPrompt("force")
                .build();
    }

    public String getRefreshToken(String code) throws Exception {

        GoogleClientSecrets.Details details =
                new GoogleClientSecrets.Details()
                        .setClientId(clientId)
                        .setClientSecret(clientSecret);

        GoogleClientSecrets secrets =
                new GoogleClientSecrets().setWeb(details);

        GoogleAuthorizationCodeFlow flow =
                new GoogleAuthorizationCodeFlow.Builder(
                        HTTP_TRANSPORT,
                        JSON_FACTORY,
                        secrets,
                        Arrays.asList(
                                "https://www.googleapis.com/auth/drive.file"
                        )
                )
                .setAccessType("offline")
                .build();

        GoogleTokenResponse response =
                flow.newTokenRequest(code)
                        .setRedirectUri(redirectUri)
                        .execute();

        return response.getRefreshToken();
    }
}