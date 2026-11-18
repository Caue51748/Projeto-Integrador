package com.backendpi.backend.security;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.Base64;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class JwtService {

    private static final String HMAC_ALGORITHM = "HmacSHA256";
    private static final String JWT_HEADER_JSON = "{\"alg\":\"HS256\",\"typ\":\"JWT\"}";
    private static final String ENCODED_HEADER = Base64.getUrlEncoder().withoutPadding()
            .encodeToString(JWT_HEADER_JSON.getBytes(StandardCharsets.UTF_8));

    private final String secretKey;
    private final long expirationMillis;

    public JwtService(
            @Value("${jwt.secret:SocialJoinChaveMestraJWT2026ParaAutenticacaoSeguraHmacSha256!#$}") String secretKey,
            @Value("${jwt.expiration-ms:604800000}") long expirationMillis
    ) {
        this.secretKey = secretKey;
        this.expirationMillis = expirationMillis;
    }

    public String gerarToken(Long idUsuario, String username, String email) {
        long agora = System.currentTimeMillis();
        long expiracao = agora + expirationMillis;

        long iatSeconds = agora / 1000L;
        long expSeconds = expiracao / 1000L;

        String payloadJson = String.format(
                "{\"sub\":%d,\"username\":\"%s\",\"email\":\"%s\",\"iat\":%d,\"exp\":%d}",
                idUsuario != null ? idUsuario : 0L,
                escapeJson(username != null ? username : ""),
                escapeJson(email != null ? email : ""),
                iatSeconds,
                expSeconds
        );

        String encodedPayload = Base64.getUrlEncoder().withoutPadding()
                .encodeToString(payloadJson.getBytes(StandardCharsets.UTF_8));

        String contentToSign = ENCODED_HEADER + "." + encodedPayload;
        String signature = sign(contentToSign);

        return contentToSign + "." + signature;
    }

    public boolean validarToken(String token) {
        if (token == null || token.trim().isEmpty()) {
            return false;
        }

        String[] parts = token.trim().split("\\.");
        if (parts.length != 3) {
            return false;
        }

        String contentToSign = parts[0] + "." + parts[1];
        String expectedSignature = sign(contentToSign);

        byte[] sigBytes = parts[2].getBytes(StandardCharsets.UTF_8);
        byte[] expectedBytes = expectedSignature.getBytes(StandardCharsets.UTF_8);

        if (!MessageDigest.isEqual(sigBytes, expectedBytes)) {
            return false;
        }

        try {
            byte[] payloadBytes = Base64.getUrlDecoder().decode(parts[1]);
            String payloadJson = new String(payloadBytes, StandardCharsets.UTF_8);

            Long exp = extrairLongDoJson(payloadJson, "exp");
            if (exp == null) {
                return false;
            }

            long agoraSegundos = System.currentTimeMillis() / 1000L;
            return agoraSegundos <= exp;
        } catch (Exception e) {
            return false;
        }
    }

    public Long extrairIdUsuario(String token) {
        String payload = extrairPayload(token);
        if (payload == null) return null;
        return extrairLongDoJson(payload, "sub");
    }

    public String extrairUsername(String token) {
        String payload = extrairPayload(token);
        if (payload == null) return null;
        return extrairStringDoJson(payload, "username");
    }

    public String extrairEmail(String token) {
        String payload = extrairPayload(token);
        if (payload == null) return null;
        return extrairStringDoJson(payload, "email");
    }

    private String extrairPayload(String token) {
        if (token == null) return null;
        String[] parts = token.trim().split("\\.");
        if (parts.length != 3) return null;

        if (!validarToken(token)) return null;

        try {
            byte[] payloadBytes = Base64.getUrlDecoder().decode(parts[1]);
            return new String(payloadBytes, StandardCharsets.UTF_8);
        } catch (Exception e) {
            return null;
        }
    }

    private String sign(String data) {
        try {
            Mac mac = Mac.getInstance(HMAC_ALGORITHM);
            SecretKeySpec keySpec = new SecretKeySpec(secretKey.getBytes(StandardCharsets.UTF_8), HMAC_ALGORITHM);
            mac.init(keySpec);
            byte[] rawHmac = mac.doFinal(data.getBytes(StandardCharsets.UTF_8));
            return Base64.getUrlEncoder().withoutPadding().encodeToString(rawHmac);
        } catch (Exception e) {
            throw new RuntimeException("Erro ao assinar token JWT", e);
        }
    }

    private String escapeJson(String valor) {
        if (valor == null) return "";
        return valor.replace("\\", "\\\\")
                    .replace("\"", "\\\"")
                    .replace("\b", "\\b")
                    .replace("\f", "\\f")
                    .replace("\n", "\\n")
                    .replace("\r", "\\r")
                    .replace("\t", "\\t");
    }

    private Long extrairLongDoJson(String json, String chave) {
        Pattern pattern = Pattern.compile("\"" + Pattern.quote(chave) + "\"\\s*:\\s*(\\d+)");
        Matcher matcher = pattern.matcher(json);
        if (matcher.find()) {
            return Long.parseLong(matcher.group(1));
        }
        return null;
    }

    private String extrairStringDoJson(String json, String chave) {
        Pattern pattern = Pattern.compile("\"" + Pattern.quote(chave) + "\"\\s*:\\s*\"([^\"]*)\"");
        Matcher matcher = pattern.matcher(json);
        if (matcher.find()) {
            return matcher.group(1);
        }
        return null;
    }
}
