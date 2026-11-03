package com.backendpi.backend.security;

import java.text.Normalizer;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.springframework.stereotype.Service;

import com.backendpi.backend.exception.ConteudoInadequadoException;

@Service
public class SecuritySanitizerService {

    // --- PADRÕES DE SQL INJECTION ---
    private static final Pattern[] SQL_INJECTION_PATTERNS = new Pattern[] {
            Pattern.compile("(?i)(--|;|/\\*|\\*/|;--)"),
            Pattern.compile("(?i)\\b(OR|AND)\\s+['\"]?\\w+['\"]?\\s*=\\s*['\"]?\\w+['\"]?"),
            Pattern.compile("(?i)\\b(OR|AND)\\s+1\\s*=\\s*1\\b"),
            Pattern.compile("(?i)\\bUNION(\\s+ALL)?\\s+SELECT\\b"),
            Pattern.compile("(?i)\\b(DROP|ALTER|TRUNCATE)\\s+(TABLE|DATABASE|SCHEMA|VIEW)\\b"),
            Pattern.compile("(?i)\\b(DELETE\\s+FROM|INSERT\\s+INTO|UPDATE\\s+\\w+\\s+SET)\\b"),
            Pattern.compile("(?i)\\b(EXEC|EXECUTE)\\s*\\("),
            Pattern.compile("(?i)\\b(XP_CMDSHELL|SP_EXECUTESQL)\\b"),
            Pattern.compile("(?i)\\b(SLEEP|BENCHMARK|LOAD_FILE)\\s*\\("),
            Pattern.compile("(?i)\\b(INFORMATION_SCHEMA|SYS\\.TABLES|DATABASE\\(\\)|VERSION\\(\\))\\b")
    };

    // --- PADRÕES DE XSS ---
    private static final Pattern[] XSS_PATTERNS = new Pattern[] {
            Pattern.compile("(?i)<script\\b[^<]*(?:(?!<\\/script>)<[^<]*)*<\\/script>"),
            Pattern.compile("(?i)src[\\r\\n]*=[\\r\\n]*['\"]?(?:javascript|vbscript):[^>'\"]*"),
            Pattern.compile("(?i)href[\\r\\n]*=[\\r\\n]*['\"]?(?:javascript|vbscript):[^>'\"]*"),
            Pattern.compile("(?i)<iframe\\b[^>]*>.*?<\\/iframe>"),
            Pattern.compile("(?i)<(object|embed|applet|meta|link)[^>]*>"),
            Pattern.compile("(?i)\\bon[a-zA-Z]+\\s*=\\s*['\"]?[^>'\"]*['\"]?")
    };

    // --- PALAVRAS INADEQUADAS / PROFANIDADE / OFENSAS ---
    private static final Set<String> PALAVRAS_INADEQUADAS = Collections.unmodifiableSet(new HashSet<>(Arrays.asList(
            "porra", "caralho", "puta", "puto", "putaria", "foder", "foda", "fudido", "fudida", "fodase",
            "merda", "bosta", "cu", "viado", "arrombado", "arrombada", "fdp", "desgraca", "desgraçado",
            "otario", "otaria", "idiota", "imbecil", "corno", "corna", "cacete", "babaca", "nazista",
            "hitler", "estupro", "pedofilia", "chupa", "buceta", "boquete", "piroca", "vagabundo",
            "vagabunda", "cuzão", "cuzao", "trouxa", "babaovo",
            "asshole", "bitch", "fuck", "shit", "bastard", "nigger", "cunt", "motherfucker", "dick",
            "pussy", "faggot", "whore", "slut"
    )));

    /**
     * Sanitiza XSS e valida contra palavras inadequadas e SQL Injection.
     * Lança ConteudoInadequadoException se violar as regras.
     * Retorna o texto sanitizado e limpo.
     */
    public String validarEModerar(String texto, String nomeCampo) {
        if (texto == null) {
            return null;
        }

        String limpo = texto.trim();
        if (limpo.isEmpty()) {
            return limpo;
        }

        // 1. Verificação de SQL Injection
        String tentativaSql = detectarSqlInjection(limpo);
        if (tentativaSql != null) {
            throw new ConteudoInadequadoException(
                    "O campo '" + nomeCampo + "' contém comandos SQL não permitidos (" + tentativaSql + ")."
            );
        }

        // 2. Verificação de Palavras Inadequadas
        String palavraInadequada = detectarPalavraInadequada(limpo);
        if (palavraInadequada != null) {
            throw new ConteudoInadequadoException(
                    "O campo '" + nomeCampo + "' contém termo inadequado não permitido: '" + palavraInadequada + "'."
            );
        }

        // 3. Sanitização XSS (remove marcações perigosas)
        return sanitizarXss(limpo);
    }

    /**
     * Remove tags HTML e padrões perigosos de XSS.
     */
    public String sanitizarXss(String texto) {
        if (texto == null) {
            return null;
        }

        String resultado = texto;
        for (Pattern pattern : XSS_PATTERNS) {
            resultado = pattern.matcher(resultado).replaceAll("");
        }

        // Neutraliza caracteres perigosos mantendo texto legível
        resultado = resultado.replace("<", "&lt;")
                             .replace(">", "&gt;");

        return resultado.trim();
    }

    /**
     * Detecta padrões de SQL Injection.
     * Retorna descrição da vulnerabilidade ou null se limpo.
     */
    public String detectarSqlInjection(String texto) {
        if (texto == null) return null;

        for (Pattern pattern : SQL_INJECTION_PATTERNS) {
            Matcher matcher = pattern.matcher(texto);
            if (matcher.find()) {
                return "Padrão SQL suspeito detectado: " + matcher.group();
            }
        }
        return null;
    }

    /**
     * Detecta palavras inadequadas utilizando normalização de acentos,
     * leetspeak (números substituindo letras) e limite de palavras.
     */
    public String detectarPalavraInadequada(String texto) {
        if (texto == null) return null;

        String normalizado = normalizarTexto(texto);

        // Quebra em tokens alfanuméricos
        String[] tokens = normalizado.split("[^a-z0-9]+");

        for (String token : tokens) {
            String tokenLimpo = token.trim();
            if (tokenLimpo.isEmpty()) continue;

            if (PALAVRAS_INADEQUADAS.contains(tokenLimpo)) {
                return tokenLimpo;
            }

            // Também verifica sem repetições (ex: "poooorra" -> "porra")
            String colapsado = colapsarRepeticoes(tokenLimpo);
            if (PALAVRAS_INADEQUADAS.contains(colapsado)) {
                return tokenLimpo;
            }
        }

        return null;
    }

    private String normalizarTexto(String texto) {
        if (texto == null) return "";

        // Remove acentos
        String decomposto = Normalizer.normalize(texto.toLowerCase(), Normalizer.Form.NFD);
        String semAcentos = decomposto.replaceAll("\\p{M}", "");

        // Converte leetspeak comum
        return semAcentos
                .replace('@', 'a')
                .replace('4', 'a')
                .replace('3', 'e')
                .replace('1', 'i')
                .replace('!', 'i')
                .replace('0', 'o')
                .replace('5', 's')
                .replace('$', 's')
                .replace('7', 't');
    }

    private String colapsarRepeticoes(String texto) {
        if (texto == null || texto.length() <= 1) return texto;
        StringBuilder sb = new StringBuilder();
        char anterior = '\0';
        for (int i = 0; i < texto.length(); i++) {
            char c = texto.charAt(i);
            if (c != anterior) {
                sb.append(c);
                anterior = c;
            }
        }
        return sb.toString();
    }
}
