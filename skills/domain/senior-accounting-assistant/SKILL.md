# senior-accounting-assistant

Auxiliar Contable Senior especializado en normativa colombiana. Cubre ciclo contable completo, impuestos, NIIF para PYMES, conciliaciones, estados financieros e indicadores de gestión.

---

## 📋 Reglas de negocio (10+)

### 1. Marco normativo colombiano vigente
Toda actuación contable debe sujetarse a:
- **Ley 1314 de 2009** — principios y normas de contabilidad e información financiera
- **DUR 2420 de 2015** — Decreto Único Reglamentario de normas contables
- **NIIF para PYMES** — aplicable a Grupos 2 y 3 según clasificación de la Supersociedades
- **Estatuto Tributario Nacional** — para efectos fiscales
- **PUC (Plan Único de Cuentas)** — codificación vigente para comerciantes

### 2. Ciclo contable completo
El proceso contable debe seguir estas fases en orden:
1. **Reconocimiento** — identificación, medición y clasificación de transacciones
2. **Registro** — causación en comprobantes diarios (ingresos, egresos, traslados)
3. **Mayorización** — traslado al libro mayor y balances
4. **Ajustes** — depreciaciones, amortizaciones, provisiones, diferidos, inventarios
5. **Cierre** — cuentas nominales, determinación de resultado integral
6. **Estados financieros** — elaboración y presentación

### 3. Clasificación de contribuyentes según DIAN
| Grupo | Base contable | Obligaciones |
|-------|--------------|--------------|
| Grupo 1 | NIIF Plenas | Estados financieros auditados, memoria económica |
| Grupo 2 | NIIF para PYMES | EEFF básicos, notas, revelaciones limitadas |
| Grupo 3 | NIIF Microempresas | Contabilidad simplificada, libro fiscal |

### 4. Manejo de retenciones en la fuente
- **Régimen Común (RCD):** retención a tarifas vigentes por concepto (honorarios 10%, servicios 4%, compras 2.5%, arrendamientos 3.5%)
- **Régimen Simplificado (RST):** no practican retención, pero sí les retienen
- **Autorretenedores:** declaran y pagan directamente
- **No declarantes:** entidades exentas según Estatuto Tributario

### 5. IVA — Impuesto al Valor Agregado
- **Bienes excluidos:** no causan IVA (alimentos básicos, libros, medicamentos)
- **Bienes exentos:** causa IVA pero tarifa 0% (exportaciones, ciertos servicios)
- **Bienes gravados:** tarifas 5%, 19% según tipo de bien/servicio
- **Responsables de IVA:** declaración bimestral o cuatrimestral según ingresos
- **Descontables:** IVA pagado en compras de bienes corporales muebles y servicios gravados

### 6. ICA — Impuesto de Industria y Comercio
- Se liquida sobre ingresos brutos ordinarios y extraordinarios del año anterior
- Tarifas varían por municipio y actividad económica (0.2% a 1.4%)
- Declaración anual en la mayoría de municipios
- Retención de ICA aplicable para ciertos agentes

### 7. Conciliaciones bancarias obligatorias
Deben realizarse dentro de los primeros 10 días hábiles del mes siguiente:
1. Confrontar saldo contable vs extracto bancario
2. Identificar partidas conciliatorias (cheques pendientes, consignaciones no abonadas, notas débito/crédito)
3. Registrar ajustes por notas bancarias no contabilizadas
4. Depurar partidas antiguas (más de 60 días)
5. Firmar y archivar soporte con evidencia

### 8. Depreciación y amortización bajo NIIF para PYMES
- **Vida útil estimada** basada en evaluación técnica, no fiscal
- **Métodos:** línea recta, unidades de producción, suma de dígitos
- **Componentización:** activos con partes significativas con vidas útiles diferentes
- **Valor residual:** estimación realista, no necesariamente cero
- **Deterioro (impairment):** evaluar anualmente si hay indicios de pérdida de valor

### 9. Provisiones y pasivos estimados
- **Provisiones:** obligación presente, probable (>50%), estimable fiablemente
- **Pasivos contingentes:** no se reconocen, se revelan en notas
- **Provisiones laborales:** cesantías, intereses, primas, vacaciones — causación mensual
- **Provisiones de cartera:** análisis de deterioro individual o colectivo

### 10. Estados financieros bajo NIIF para PYMES
Conjunto completo (Sección 3 NIIF PYMES):
- **Estado de Situación Financiera** — activos, pasivos, patrimonio
- **Estado de Resultado Integral** — ingresos, costos, gastos, otro resultado integral
- **Estado de Cambios en el Patrimonio** — movimientos de cada componente patrimonial
- **Estado de Flujos de Efectivo** — método directo o indirecto
- **Notas a los Estados Financieros** — políticas contables, revelaciones, riesgos

### 11. Cierre fiscal anual
1. Depuración de ingresos (no constitutivos de renta)
2. Cálculo de renta líquida gravable vs renta presuntiva
3. Determinación de impuesto neto de renta (tarifa general 35%)
4. Descontar retenciones del año, anticipos y autorretenciones
5. Liquidar sobretasa si aplica (ingresos > 120.000 UVT)
6. Presentar formulario 110 ante la DIAN

### 12. Indicadores financieros clave

| Indicador | Fórmula | Interpretación |
|-----------|---------|----------------|
| Razón corriente | AC / PC | Capacidad de pago a corto plazo (>1.5 sano) |
| Prueba ácida | (AC - Inventario) / PC | Liquidez sin inventarios (>1.0 aceptable) |
| Endeudamiento | Total Pasivo / Total Activo | Nivel de apalancamiento (<60% sano) |
| ROE | Utilidad neta / Patrimonio | Rentabilidad sobre inversión de socios |
| EBITDA | Utilidad operativa + D&A + Provisiones | Generación operativa de caja |
| Ciclo de efectivo | Días inventario + Días cartera - Días proveedores | Eficiencia del capital de trabajo |

---

## 🧩 Snippets de código

### Snippet 1: Cálculo de retención en la fuente
```python
from decimal import Decimal, ROUND_HALF_UP
from dataclasses import dataclass

@dataclass
class RetencionConfig:
    concepto: str
    base_minima_uvt: int       # UVT
    tarifa: Decimal             # ej: Decimal("0.10")
    aplica_sobre: str           # "total" | "excedente"

TARIFAS_RETEFUENTE: dict[str, RetencionConfig] = {
    "honorarios": RetencionConfig("honorarios", 0, Decimal("0.10"), "total"),
    "servicios": RetencionConfig("servicios", 4, Decimal("0.04"), "excedente"),
    "compras": RetencionConfig("compras", 27, Decimal("0.025"), "excedente"),
    "arrendamientos": RetencionConfig("arrendamientos", 0, Decimal("0.035"), "total"),
}

UVT_ANUAL: dict[int, Decimal] = {
    2026: Decimal("49799"),   # valor UVT proyectado
}

def calcular_retencion(
    valor: Decimal,
    concepto: str,
    año: int = 2026,
) -> Decimal | None:
    """Calcula la retención en la fuente según tarifas vigentes."""
    config = TARIFAS_RETEFUENTE.get(concepto)
    if not config:
        return None

    uvt = UVT_ANUAL.get(año)
    if not uvt:
        raise ValueError(f"UVT no disponible para año {año}")

    base_minima = Decimal(config.base_minima_uvt) * uvt
    if valor < base_minima:
        return Decimal("0.00")

    if config.aplica_sobre == "excedente":
        base = valor - base_minima
    else:
        base = valor

    return (base * config.tarifa).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)
```

### Snippet 2: Depreciación línea recta
```python
@dataclass
class ActivoFijo:
    codigo: str
    nombre: str
    costo_historico: Decimal
    valor_residual: Decimal
    vida_util_meses: int
    fecha_adquisicion: date
    depreciacion_acumulada: Decimal = Decimal("0")

    def depreciacion_mensual(self) -> Decimal:
        base = self.costo_historico - self.valor_residual
        return (base / Decimal(self.vida_util_meses)).quantize(
            Decimal("0.01"), rounding=ROUND_HALF_UP
        )

    def valor_neto(self) -> Decimal:
        return self.costo_historico - self.depreciacion_acumulada

    def registrar_depreciacion(self, meses: int = 1) -> None:
        """Acumula depreciación por el número de meses indicado."""
        self.depreciacion_acumulada += self.depreciacion_mensual() * Decimal(meses)

    def fecha_fin_vida_util(self) -> date:
        import calendar
        mes = self.fecha_adquisicion.month + self.vida_util_meses
        año = self.fecha_adquisicion.year + (mes - 1) // 12
        mes = ((mes - 1) % 12) + 1
        ultimo_dia = calendar.monthrange(año, mes)[1]
        return date(año, mes, ultimo_dia)
```

### Snippet 3: Conciliación bancaria
```python
@dataclass
class PartidaConciliatoria:
    tipo: str            # "cheque_pendiente", "consignacion_no_abonada", "nota_debito", "nota_credito"
    valor: Decimal
    referencia: str
    fecha: date
    contabilizado: bool  # True = está en libros pero no en banco

@dataclass
class ConciliacionBancaria:
    saldo_libros: Decimal
    saldo_extracto: Decimal
    partidas: list[PartidaConciliatoria]

    def ejecutar(self) -> dict:
        """Ejecuta conciliación y retorna saldos ajustados."""
        mas_en_libros = Decimal("0")
        menos_en_libros = Decimal("0")
        mas_en_banco = Decimal("0")
        menos_en_banco = Decimal("0")

        for p in self.partidas:
            if p.contabilizado:
                if p.tipo in ("nota_debito",):
                    menos_en_banco += p.valor
                elif p.tipo in ("nota_credito",):
                    mas_en_banco += p.valor
            else:
                if p.tipo == "cheque_pendiente":
                    mas_en_libros += p.valor
                elif p.tipo == "consignacion_no_abonada":
                    menos_en_banco += p.valor

        saldo_libros_ajustado = self.saldo_libros + mas_en_libros - menos_en_libros
        saldo_extracto_ajustado = self.saldo_extracto + mas_en_banco - menos_en_banco
        diferencia = saldo_libros_ajustado - saldo_extracto_ajustado

        return {
            "saldo_libros_ajustado": saldo_libros_ajustado,
            "saldo_extracto_ajustado": saldo_extracto_ajustado,
            "diferencia": diferencia,
            "conciliado": diferencia == Decimal("0"),
            "partidas_pendientes": len(self.partidas),
        }
```

### Snippet 4: Estado de resultados simplificado
```python
@dataclass
class CuentaContable:
    codigo: str
    nombre: str
    saldo: Decimal
    clase: str  # "ingreso", "costo", "gasto", "activo", "pasivo", "patrimonio"

class EstadoResultados:
    def __init__(self, cuentas: list[CuentaContable]):
        self.cuentas = cuentas

    def total_ingresos(self) -> Decimal:
        return sum(
            c.saldo for c in self.cuentas
            if c.clase == "ingreso" and c.codigo.startswith("4")
        )

    def total_costos(self) -> Decimal:
        return sum(
            c.saldo for c in self.cuentas
            if c.clase == "costo" and c.codigo.startswith("6")
        )

    def total_gastos(self) -> Decimal:
        return sum(
            c.saldo for c in self.cuentas
            if c.clase == "gasto" and c.codigo.startswith("5")
        )

    def resultado_operacional(self) -> Decimal:
        return self.total_ingresos() - self.total_costos() - self.total_gastos()

    def utilidad_neta(self, impuesto_renta: Decimal) -> Decimal:
        return self.resultado_operacional() - impuesto_renta

    def resumen(self) -> dict:
        return {
            "ingresos_operacionales": self.total_ingresos(),
            "costos_operacionales": self.total_costos(),
            "gastos_operacionales": self.total_gastos(),
            "resultado_operacional": self.resultado_operacional(),
        }
```

### Snippet 5: Cálculo de IVA descontable
```python
def calcular_iva_descontable(
    compras_grabadas: list[tuple[Decimal, Decimal]],
    compras_excluidas: list[Decimal],
    es_exportador: bool = False,
) -> dict:
    """
    Calcula IVA descontable.
    Cada tupla en compras_grabadas = (base_gravada, tarifa_iva)
    compras_excluidas = lista de valores de compras excluidas (no generan IVA)
    """
    iva_generado = Decimal("0")
    base_total = Decimal("0")

    for base, tarifa in compras_grabadas:
        iva_generado += base * Decimal(str(tarifa)) / Decimal("100")
        base_total += base

    iva_excluidas = sum(compras_excluidas) * Decimal("0")  # siempre 0
    total_compras = base_total + sum(compras_excluidas)

    return {
        "iva_descontable": iva_generado.quantize(Decimal("0.01")),
        "base_total_gravada": base_total,
        "compras_excluidas": sum(compras_excluidas),
        "total_compras": total_compras,
        "iva_a_pagar_despues_descontable": None,  # se completa con ventas
    }
```

### Snippet 6: Indicadores financieros
```python
@dataclass
class IndicadoresFinancieros:
    activo_corriente: Decimal
    pasivo_corriente: Decimal
    activo_total: Decimal
    pasivo_total: Decimal
    patrimonio: Decimal
    utilidad_neta: Decimal
    ingresos_operacionales: Decimal
    inventario: Decimal

    def razon_corriente(self) -> Decimal:
        if self.pasivo_corriente == Decimal("0"):
            return Decimal("0")
        return (self.activo_corriente / self.pasivo_corriente).quantize(Decimal("0.01"))

    def prueba_acida(self) -> Decimal:
        if self.pasivo_corriente == Decimal("0"):
            return Decimal("0")
        return ((self.activo_corriente - self.inventario) / self.pasivo_corriente).quantize(Decimal("0.01"))

    def endeudamiento(self) -> Decimal:
        if self.activo_total == Decimal("0"):
            return Decimal("0")
        porcentaje = (self.pasivo_total / self.activo_total) * Decimal("100")
        return porcentaje.quantize(Decimal("0.01"))

    def roe(self) -> Decimal:
        if self.patrimonio == Decimal("0"):
            return Decimal("0")
        porcentaje = (self.utilidad_neta / self.patrimonio) * Decimal("100")
        return porcentaje.quantize(Decimal("0.01"))

    def margen_neto(self) -> Decimal:
        if self.ingresos_operacionales == Decimal("0"):
            return Decimal("0")
        porcentaje = (self.utilidad_neta / self.ingresos_operacionales) * Decimal("100")
        return porcentaje.quantize(Decimal("0.01"))

    def generar_reporte(self) -> str:
        return f"""
INDICADORES FINANCIEROS
━━━━━━━━━━━━━━━━━━━━━
Liquidez:
  Razón corriente:     {self.razon_corriente():>8}
  Prueba ácida:        {self.prueba_acida():>8}
Endeudamiento:
  Nivel:               {self.endeudamiento():>7}%
Rentabilidad:
  ROE:                 {self.roe():>7}%
  Margen neto:         {self.margen_neto():>7}%
        """.strip()
```

---

## ✅ Checks de validación

| # | Check | Descripción |
|---|-------|-------------|
| 1 | `normativa_vigente` | Se referencia la normativa colombiana correcta y actualizada |
| 2 | `puc_correcto` | Códigos PUC usados corresponden a la clase y grupo correctos |
| 3 | `bases_retencion` | Cálculo de retención usa UVT del año correspondiente |
| 4 | `iva_tarifa_correcta` | Tarifa de IVA aplicada coincide con el tipo de bien/servicio |
| 5 | `conciliacion_completa` | Partidas conciliatorias identificadas y depuradas |
| 6 | `depreciacion_consistente` | Vida útil y método de depreciación son consistentes entre períodos |
| 7 | `causacion_mensual` | Provisiones laborales y gastos se causan mensualmente |
| 8 | `eeff_completos` | Juego completo de estados financieros según Sección 3 NIIF PYMES |
| 9 | `cierre_ordenado` | Cierre contable precede al fiscal; cuentas nominales quedan en cero |
| 10 | `impuesto_renta_calculado` | Depuración de renta incluye ingresos no constitutivos y costos deducibles |
| 11 | `indicadores_calculados` | Todos los indicadores clave tienen su fórmula e interpretación |
| 12 | `soportes_archivados` | Cada registro contable tiene su soporte documental asociado |

---

## 📚 Referencias

- Ley 1314 de 2009 — principios de contabilidad e información financiera
- DUR 2420 de 2015 — Decreto Único Reglamentario de normas contables
- NIIF para PYMES — IASB (versión 2009 + modificaciones 2015)
- Estatuto Tributario Nacional — artículos 1 a 257-1
- PUC — Plan Único de Cuentas para comerciantes (Decreto 2650 de 1993)
- DIAN — Conceptos tributarios y doctrina oficial
- Supersociedades — Circular externa de clasificación de grupos
- UVT — Unidad de Valor Tributario (actualizable anualmente)
