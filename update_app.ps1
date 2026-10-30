$path = "web/js/app.js"
$c = [System.IO.File]::ReadAllText((Resolve-Path $path).Path)
$c_norm = $c.Replace("`r`n", "`n")

# 1. Update limparFormularioEvento
$targetLimpar = @"
        this.atualizarPreviewCapaEvento(capaInput);
        this.mostrarEventoFeedback('');
    }
"@.Replace("`r`n", "`n")

$replaceLimpar = @"
        this.atualizarPreviewCapaEvento(capaInput);
        const fmt = document.getElementById('evento-formato-local');
        if (fmt) fmt.value = 'presencial';
        this.alternarFormatoCriacaoEvento('presencial');
        const lat = document.getElementById('evento-latitude');
        if (lat) lat.value = '';
        const lng = document.getElementById('evento-longitude');
        if (lng) lng.value = '';
        this.atualizarBadgeCoordsEvento('evento-coords-badge', null, null);
        this.mostrarEventoFeedback('');
    }
"@.Replace("`r`n", "`n")

if ($c_norm.Contains($targetLimpar)) {
    $c_norm = $c_norm.Replace($targetLimpar, $replaceLimpar)
    Write-Host "1. limparFormularioEvento updated"
} else {
    Write-Host "1. targetLimpar not found"
}

# 2. Update criarEvento
$targetNovoEvento = @"
        const novoEvento = {
            titulo,
            descricao,
            categoria: categoria || null,
            dataEvento,
            horarioInicio: horarioInicio + ":00",
            horarioFim: horarioFim + ":00",
            encerramentoInscricoes: encerramentoInscricoes
                ? encerramentoInscricoes + ":00"
                : null,
            localEvento,
            criadorId: parseInt(idUsuario),
            comunidadeId: comunidadeValor
                ? parseInt(comunidadeValor)
                : null,
            limiteParticipantes: limiteValor
                ? parseInt(limiteValor)
                : null,

            precoIngresso,

            exigeCheckin
        };
"@.Replace("`r`n", "`n")

$replaceNovoEvento = @"
        let latitude = null;
        let longitude = null;
        const latValor = document.getElementById('evento-latitude')?.value;
        const lngValor = document.getElementById('evento-longitude')?.value;
        if (latValor && lngValor) {
            latitude = parseFloat(latValor);
            longitude = parseFloat(lngValor);
        } else {
            const formatoLocal = document.getElementById('evento-formato-local')?.value;
            if (formatoLocal !== 'online' && localEvento) {
                try {
                    const coords = await ApiService.buscarCoordenadasPorEndereco(localEvento);
                    if (coords) {
                        latitude = coords.lat;
                        longitude = coords.lng;
                    }
                } catch (e) {
                    console.warn('Geocodificação automática:', e);
                }
            }
        }

        const novoEvento = {
            titulo,
            descricao,
            categoria: categoria || null,
            dataEvento,
            horarioInicio: horarioInicio + ":00",
            horarioFim: horarioFim + ":00",
            encerramentoInscricoes: encerramentoInscricoes
                ? encerramentoInscricoes + ":00"
                : null,
            localEvento,
            latitude,
            longitude,
            criadorId: parseInt(idUsuario),
            comunidadeId: comunidadeValor
                ? parseInt(comunidadeValor)
                : null,
            limiteParticipantes: limiteValor
                ? parseInt(limiteValor)
                : null,

            precoIngresso,

            exigeCheckin
        };
"@.Replace("`r`n", "`n")

if ($c_norm.Contains($targetNovoEvento)) {
    $c_norm = $c_norm.Replace($targetNovoEvento, $replaceNovoEvento)
    Write-Host "2. criarEvento updated"
} else {
    Write-Host "2. targetNovoEvento not found"
}

# 3. Update gerenciarEvento
$targetGerenciar = @"
        document.getElementById('editar-evento-checkin').checked =
            evento.exigeCheckin === true;

        this.abrirModal('gerenciar-evento-modal');
"@.Replace("`r`n", "`n")

$replaceGerenciar = @"
        document.getElementById('editar-evento-checkin').checked =
            evento.exigeCheckin === true;

        const latEdit = document.getElementById('editar-evento-latitude');
        const lngEdit = document.getElementById('editar-evento-longitude');
        if (latEdit) latEdit.value = (evento.latitude != null) ? evento.latitude : '';
        if (lngEdit) lngEdit.value = (evento.longitude != null) ? evento.longitude : '';

        const isOnline = /^(https?:\/\/|www\.)/i.test(evento.localEvento || '');
        const formatoSelect = document.getElementById('editar-evento-formato-local');
        if (formatoSelect) formatoSelect.value = isOnline ? 'online' : 'presencial';
        this.alternarFormatoEdicaoEvento(isOnline ? 'online' : 'presencial');

        if (evento.latitude != null && evento.longitude != null) {
            this.atualizarBadgeCoordsEvento('editar-evento-coords-badge', evento.latitude, evento.longitude);
        } else {
            this.atualizarBadgeCoordsEvento('editar-evento-coords-badge', null, null);
        }

        this.abrirModal('gerenciar-evento-modal');
"@.Replace("`r`n", "`n")

if ($c_norm.Contains($targetGerenciar)) {
    $c_norm = $c_norm.Replace($targetGerenciar, $replaceGerenciar)
    Write-Host "3. gerenciarEvento updated"
} else {
    Write-Host "3. targetGerenciar not found"
}

# 4. Update salvarEdicaoEvento
$targetSalvarEdicao = @"
        const eventoAtualizado = {
            titulo,
            descricao,
            categoria: categoria || null,
            dataEvento,

            horarioInicio: horarioInicio + ":00",
            horarioFim: horarioFim + ":00",

            encerramentoInscricoes:
                encerramentoInscricoes
                    ? encerramentoInscricoes + ":00"
                    : null,

            localEvento,

            comunidadeId:
                comunidadeValor
                    ? parseInt(comunidadeValor)
                    : null,

            limiteParticipantes:
                limiteValor
                    ? parseInt(limiteValor)
                    : null,

            exigeCheckin
        };
"@.Replace("`r`n", "`n")

$replaceSalvarEdicao = @"
        let latitude = null;
        let longitude = null;
        const latValor = document.getElementById('editar-evento-latitude')?.value;
        const lngValor = document.getElementById('editar-evento-longitude')?.value;
        if (latValor && lngValor) {
            latitude = parseFloat(latValor);
            longitude = parseFloat(lngValor);
        } else {
            const formatoLocal = document.getElementById('editar-evento-formato-local')?.value;
            if (formatoLocal !== 'online' && localEvento) {
                try {
                    const coords = await ApiService.buscarCoordenadasPorEndereco(localEvento);
                    if (coords) {
                        latitude = coords.lat;
                        longitude = coords.lng;
                    }
                } catch (e) {
                    console.warn('Geocodificação automática na edição:', e);
                }
            }
        }

        const eventoAtualizado = {
            titulo,
            descricao,
            categoria: categoria || null,
            dataEvento,

            horarioInicio: horarioInicio + ":00",
            horarioFim: horarioFim + ":00",

            encerramentoInscricoes:
                encerramentoInscricoes
                    ? encerramentoInscricoes + ":00"
                    : null,

            localEvento,
            latitude,
            longitude,

            comunidadeId:
                comunidadeValor
                    ? parseInt(comunidadeValor)
                    : null,

            limiteParticipantes:
                limiteValor
                    ? parseInt(limiteValor)
                    : null,

            exigeCheckin
        };
"@.Replace("`r`n", "`n")

if ($c_norm.Contains($targetSalvarEdicao)) {
    $c_norm = $c_norm.Replace($targetSalvarEdicao, $replaceSalvarEdicao)
    Write-Host "4. salvarEdicaoEvento updated"
} else {
    Write-Host "4. targetSalvarEdicao not found"
}

# 5. Update filtrarEventos
$targetFiltro = @"
        this.filtrosEventos = {
            texto: texto || null,

            comunidadeId:
                comunidadeId
                    ? parseInt(comunidadeId)
                    : null,

            status:
                status || null,

            categoria:
                categoria || null,

            dataInicio,
            dataFim
        };
"@.Replace("`r`n", "`n")

$replaceFiltro = @"
        const latFiltro = (this.filtroProximidadeAtivo && this.coordenadasUsuario) ? this.coordenadasUsuario.lat : null;
        const lngFiltro = (this.filtroProximidadeAtivo && this.coordenadasUsuario) ? this.coordenadasUsuario.lng : null;
        const raioFiltro = Number(document.getElementById('filtro-evento-raio')?.value || 50);

        this.filtrosEventos = {
            texto: texto || null,

            comunidadeId:
                comunidadeId
                    ? parseInt(comunidadeId)
                    : null,

            status:
                status || null,

            categoria:
                categoria || null,

            dataInicio,
            dataFim,
            lat: latFiltro,
            lng: lngFiltro,
            raioKm: raioFiltro
        };
"@.Replace("`r`n", "`n")

if ($c_norm.Contains($targetFiltro)) {
    $c_norm = $c_norm.Replace($targetFiltro, $replaceFiltro)
    Write-Host "5. filtrarEventos updated"
} else {
    Write-Host "5. targetFiltro not found"
}

# 6. Card Distance in carregarEventos
$targetCard = "div.className = 'evento-card';"
$replaceCard = @"
div.className = 'evento-card';

                    let badgeDistanciaHtml = '';
                    if (this.coordenadasUsuario && evento.latitude != null && evento.longitude != null) {
                        const distKm = ApiService.calcularDistanciaKm(
                            this.coordenadasUsuario.lat,
                            this.coordenadasUsuario.lng,
                            evento.latitude,
                            evento.longitude
                        );
                        if (distKm !== null) {
                            const textoDist = distKm < 1 ? `$`{Math.round(distKm * 1000)} m` : `$`{distKm.toFixed(1)} km`;
                            badgeDistanciaHtml = `<span class="badge-distancia" title="Distância estimada de você"><i class="material-icons">near_me</i> `$`{textoDist}</span>`;
                        }
                    }
"@.Replace("`r`n", "`n")

if ($c_norm.Contains($targetCard)) {
    $c_norm = $c_norm.Replace($targetCard, $replaceCard)
    $c_norm = $c_norm.Replace('📍 ${evento.localEvento}', '📍 ${evento.localEvento} ${badgeDistanciaHtml}')
    Write-Host "6. Card distance in carregarEventos updated"
} else {
    Write-Host "6. targetCard not found"
}

# 7. abrirDetalhesEvento for Google Maps
$targetDetalhesLocal = @"
                    <div>
                        <span>Local</span>
                        <strong>
                            `${this.escaparHtmlDestaque(
                evento.localEvento ||
                'A confirmar'
            )}`
                        </strong>
                    </div>
"@.Replace("`r`n", "`n")

$replaceDetalhesLocal = @"
                    <div>
                        <span>Local</span>
                        <strong>
                            `${this.escaparHtmlDestaque(
                evento.localEvento ||
                'A confirmar'
            )}`
                        </strong>
                        `${isLink ? `
                            <a href="`${evento.localEvento.startsWith('http') ? evento.localEvento : 'https://' + evento.localEvento}" target="_blank" rel="noopener noreferrer" class="evento-rota-btn">
                                <i class="material-icons">launch</i> Acessar transmissão
                            </a>
                        ` : (evento.latitude != null && evento.longitude != null ? `
                            <a href="https://www.google.com/maps/search/?api=1&query=`${evento.latitude},`${evento.longitude}" target="_blank" rel="noopener noreferrer" class="evento-rota-btn">
                                <i class="material-icons">directions</i> Ver rota no Google Maps
                            </a>
                        ` : (evento.localEvento ? `
                            <a href="https://www.google.com/maps/search/?api=1&query=`${encodeURIComponent(evento.localEvento)}" target="_blank" rel="noopener noreferrer" class="evento-rota-btn">
                                <i class="material-icons">directions</i> Ver no Google Maps
                            </a>
                        ` : ''))}`
                    </div>
"@.Replace("`r`n", "`n")

if ($c_norm.Contains($targetDetalhesLocal)) {
    $c_norm = $c_norm.Replace("const eventoEncerrado =", "const isLink = /^(https?:\/\/|www\.)/i.test(evento.localEvento || '');`n        const eventoEncerrado =")
    $c_norm = $c_norm.Replace($targetDetalhesLocal, $replaceDetalhesLocal)
    Write-Host "7. abrirDetalhesEvento Google Maps button updated"
} else {
    Write-Host "7. targetDetalhesLocal not found"
}

$c_final = $c_norm.Replace("`n", "`r`n")
[System.IO.File]::WriteAllText((Resolve-Path $path).Path, $c_final, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "Done saving web/js/app.js!"

