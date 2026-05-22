# MQTT Contract — OPERA CRAT Carmo

Versão: 1.0.0 — congelada em 2026-05-12.

Broker: Eclipse Mosquitto 2 (porta 1883 interna / 11883 externa).  
QoS padrão: 0 para telemetria, 1 para estado e comandos.

---

## Tópicos publicados pelo Simulador

### VRP — Válvula Redutora de Pressão (Vectora)

```
BR/SP/<MUNI>/VRP/<NAME>/PRGE/VECTORA/Medicao
BR/SP/<MUNI>/VRP/<NAME>/PRGE/VECTORA/Status
```

| Parâmetro | Valores                                              |
|-----------|------------------------------------------------------|
| `<MUNI>`  | `SAO`                                                |
| `<NAME>`  | `John_Speers`, `Mizutani`, `Guilherme_da_Cruz`, `Sho_Yoshioka`, `Tomoishi_Shimizu_I`, `Tomoishi_Shimizu_II`, `Go_Sugaya`, `Ione_Pinelli`, `Jacu_Pessego` |

**Payload `Medicao`** (QoS 0, retain false):
```json
{
  "ts":  "2026-05-12T01:10:00.000Z",
  "pm":  133.2,
  "pj":  30.0,
  "vz":  20.2,
  "pos": 22.5,
  "sp":  30.0
}
```

| Campo | Tipo    | Unidade | Descrição                          |
|-------|---------|---------|------------------------------------|
| `ts`  | string  | ISO 8601| Timestamp UTC                      |
| `pm`  | float   | mca     | Pressão a montante da VRP          |
| `pj`  | float   | mca     | Pressão a jusante (controlada)     |
| `vz`  | float   | l/s     | Vazão através da VRP               |
| `pos` | float   | %       | Posição estimada (0=fechada)       |
| `sp`  | float   | mca     | Setpoint ativo                     |

**Payload `Status`** (QoS 1, retain true):
```json
{
  "ts":  "2026-05-12T01:10:00.000Z",
  "onl": 1,
  "sp":  30.0,
  "md":  "auto"
}
```

---

### CRAT — Reservatório + Bombas

```
BR/SP/SAO/CRAT/CARMO/PRGE/SCADA/Medicao
BR/SP/SAO/CRAT/CARMO/PRGE/SCADA/Status
BR/SP/SAO/CRAT/CARMO/PRGE/SCADA/Cmd/Ack
```

**Payload `Medicao`** (QoS 0):
```json
{
  "ts":          "2026-05-12T01:10:00.000Z",
  "h":           3.01,
  "v":           3010.0,
  "q_in":        141.7,
  "q_out":       141.7,
  "q_adducao":   0.0,
  "p_saida":     -2.0,
  "pumps_on":    [true, true, false],
  "pump_power_kw": 87.3
}
```

| Campo           | Tipo    | Unidade | Descrição                                  |
|-----------------|---------|---------|--------------------------------------------|
| `h`             | float   | m       | Nível do tanque CRAT                       |
| `v`             | float   | m³      | Volume no tanque                           |
| `q_in`          | float   | l/s     | Vazão de recalque (bombas → rede)          |
| `q_out`         | float   | l/s     | Vazão total pelas DMAs                     |
| `q_adducao`     | float   | l/s     | Adução Cantareira → tanque                 |
| `p_saida`       | float   | mca     | Pressão de saída do barrilete              |
| `pumps_on`      | bool[]  | —       | Status das 3 bombas [P1, P2, P3]           |
| `pump_power_kw` | float   | kW      | Potência total ativa                       |

**Payload `Status`** (QoS 1, retain true):
```json
{
  "ts":            "2026-05-12T01:10:00.000Z",
  "h":             3.01,
  "pumps_on":      [true, true, false],
  "pump_mode":     "auto",
  "pump_sp_h":     3.5,
  "pump_dead_band": 1.0,
  "alarme":        null,
  "controller_log": []
}
```

---

### MM — Macromedidores de Zona

```
BR/SP/SAO/MM/<ZONA>/PRGE/SCADA/Medicao
```

| `<ZONA>` | Área                    |
|----------|-------------------------|
| `BAIXA`  | Zona Baixa (720 m)      |
| `MEDIA`  | Zona Média (760 m)      |
| `ALTA1`  | Zona Alta-1 (790–810 m) |
| `ALTA2`  | Zona Alta-2 (815–825 m) |

**Payload `Medicao`** (QoS 0):
```json
{
  "ts":   "2026-05-12T01:10:00.000Z",
  "q":    142.5,
  "p_avg": 28.3
}
```

---

## Tópicos de Comando (API → Simulador)

### Setpoint VRP

```
BR/SP/SAO/VRP/<NAME>/PRGE/VECTORA/Config
```

**Payload**:
```json
{
  "cid":     "uuid-v4",
  "ts":      "2026-05-12T01:10:00.000Z",
  "setpoint": 32.0
}
```

### Comando CRAT

```
BR/SP/SAO/CRAT/CARMO/PRGE/SCADA/Cmd
```

**Payload**:
```json
{
  "cid":    "uuid-v4",
  "ts":     "2026-05-12T01:10:00.000Z",
  "action": "set_pump",
  "params": {"pump": 2, "on": false}
}
```

**Ações disponíveis:**

| `action`       | Params                              |
|----------------|-------------------------------------|
| `set_pump`     | `{"pump": 1|2|3, "on": bool}`      |
| `set_pump_mode`| `{"mode": "auto"|"manual"}`        |
| `set_sp_h`     | `{"sp_h": float}`                  |

### Ack de Comando

```
BR/SP/SAO/CRAT/CARMO/PRGE/SCADA/Cmd/Ack
BR/SP/SAO/VRP/<NAME>/PRGE/VECTORA/Ack
```

**Payload**:
```json
{
  "cid": "uuid-v4",
  "ts":  "2026-05-12T01:10:01.000Z",
  "ok":  true
}
```

---

## Mapeamento VRP nome → SID

| VRP Name             | SID              | Zona     | Display                  |
|----------------------|------------------|----------|--------------------------|
| `John_Speers`        | VRP-SAO-CRM-001  | baixa    | John Speers              |
| `Mizutani`           | VRP-SAO-CRM-002  | media    | Shinzamburo Mizutani     |
| `Guilherme_da_Cruz`  | VRP-SAO-CRM-003  | alta     | Guilherme da Cruz        |
| `Sho_Yoshioka`       | VRP-SAO-CRM-004  | alta     | Sho Yoshioka             |
| `Tomoishi_Shimizu_I` | VRP-SAO-CRM-005  | alta     | Tomoishi Shimizu I       |
| `Tomoishi_Shimizu_II`| VRP-SAO-CRM-006  | alta     | Tomoishi Shimizu II      |
| `Go_Sugaya`          | VRP-SAO-CRM-007  | altissima| Go Sugaya                |
| `Ione_Pinelli`       | VRP-SAO-CRM-008  | altissima| Ione Pinelli             |
| `Jacu_Pessego`       | VRP-SAO-CRM-009  | altissima| Jacu Pessego             |

---

## Regras de qualidade de dados

- **`good`**: dado chegou dentro dos últimos 10 s.  
- **`stale`**: dado entre 10 s e 60 s.  
- **`offline`**: dado mais antigo que 60 s ou ausente.  
- Valores `null` em qualquer campo numérico indicam dado indisponível.

---

## Notas de compatibilidade

- Broker externo via OPERA Bridge: republica em `OPERA/poc/+` (prefixo DST).  
- QoS downgrade: publicações QoS 0 podem ser perdidas sem notificação.  
- Retain: tópicos de Status têm `retain=true` — novos subscribers recebem o último estado imediatamente.
