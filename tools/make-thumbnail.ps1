# Mod thumbnail: 512x512 PNG, for the launcher's mod list and the Workshop page.
# descriptor.mod points at it with picture="thumbnail.png".
#
#   pwsh tools/make-thumbnail.ps1 KoreaMod
#
# Drawn at 4x and filtered down - the trigram bars are thin enough that
# drawing them at 512 directly leaves them ragged.
#
# The emblem takes the upper two thirds and the title the lower third, and
# nothing may reach the edge. The title block is flowed from the measured
# height of each line: the font's own leading is generous, and guessing at
# it is what put the first version's title through the bottom trigrams.

Add-Type -AssemblyName System.Drawing
$ErrorActionPreference = 'Stop'

$SS = 4
$N  = 512

function C([int]$r, [int]$g, [int]$b) { [System.Drawing.Color]::FromArgb(255, $r, $g, $b) }
function B($col) { New-Object System.Drawing.SolidBrush($col) }

$RED    = C 205 46 58
$BLUE   = C 0 71 160
$INK    = C 232 227 214     # trigrams, on a dark field
$GOLD   = C 216 178 94
$TITLE  = C 244 241 233
$MUTED  = C 158 163 176
$BG_TOP = C 13 17 24
$BG_BOT = C 30 38 52

function Draw-Taeguk($g, [double]$cx, [double]$cy, [double]$r, [double]$rot) {
    $st = $g.Save()
    $g.TranslateTransform([single]$cx, [single]$cy)
    $g.RotateTransform([single]$rot)
    $br = B $RED
    $bb = B $BLUE
    $d = [single](2 * $r)
    $g.FillPie($br, [single](-$r), [single](-$r), $d, $d, 180, 180)
    $g.FillPie($bb, [single](-$r), [single](-$r), $d, $d, 0, 180)
    $h = $r / 2
    $g.FillEllipse($br, [single](-$r), [single](-$h), [single]$r, [single]$r)
    $g.FillEllipse($bb, [single]0, [single](-$h), [single]$r, [single]$r)
    $br.Dispose(); $bb.Dispose()
    $g.Restore($st)
}

function Draw-Trigram($g, [double]$cx, [double]$cy, [double]$ang, [double]$len, [double]$thick, [double]$gap, [bool[]]$pattern, $col) {
    $st = $g.Save()
    $g.TranslateTransform([single]$cx, [single]$cy)
    $g.RotateTransform([single]$ang)
    $brush = B $col
    $step = $thick + $gap
    for ($i = 0; $i -lt 3; $i++) {
        $x = ($i - 1) * $step - $thick / 2
        if ($pattern[$i]) {
            $g.FillRectangle($brush, [single]$x, [single](-$len / 2), [single]$thick, [single]$len)
        } else {
            $seg = $len / 3
            $g.FillRectangle($brush, [single]$x, [single](-$len / 2), [single]$thick, [single]$seg)
            $g.FillRectangle($brush, [single]$x, [single]($len / 2 - $seg), [single]$thick, [single]$seg)
        }
    }
    $brush.Dispose()
    $g.Restore($st)
}

function Center-Text($g, [string]$s, $font, $brush, [double]$cx, [double]$y) {
    $sz = $g.MeasureString($s, $font)
    $g.DrawString($s, $font, $brush, [single]($cx - $sz.Width / 2), [single]$y)
    return $sz
}

$W = $N * $SS
$bmp = New-Object System.Drawing.Bitmap($W, $W, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

# field
$rect = New-Object System.Drawing.Rectangle 0, 0, $W, $W
$grad = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, $BG_TOP, $BG_BOT, 90.0)
$g.FillRectangle($grad, $rect)
$grad.Dispose()

$u = $W / 512.0        # everything below is written in 512-space

# The emblem sits in the upper two thirds; the bottom third is the title's,
# and nothing is allowed to reach into it or off the edge.
$cx = 256 * $u
$cy = 186 * $u
$r  = 74 * $u
Draw-Taeguk $g $cx $cy $r -33.69

$len   = 1.30 * $r
$thick = $len / 8
$gap   = $thick / 2
$d     = 1.95 * $r
$corners = @(
    @(-1, -1, @($true,  $true,  $true )),   # geon
    @(-1,  1, @($true,  $false, $true )),   # ri
    @( 1, -1, @($false, $true,  $false)),   # gam
    @( 1,  1, @($false, $false, $false))    # gon
)
foreach ($s in $corners) {
    $ux = [double]$s[0] / [Math]::Sqrt(2)
    $uy = [double]$s[1] / [Math]::Sqrt(2)
    $ang = [Math]::Atan2($uy, $ux) * 180 / [Math]::PI
    Draw-Trigram $g ($cx + $ux * $d) ($cy + $uy * $d) $ang $len $thick $gap ([bool[]]$s[2]) $INK
}

# title block
$fTitle = New-Object System.Drawing.Font('Malgun Gothic', [single](62 * $u), [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$fSub   = New-Object System.Drawing.Font('Malgun Gothic', [single](23 * $u), [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$bTitle = B $TITLE
$bMuted = B $MUTED
$bGold  = B $GOLD

# Flowed from the measured height of each line rather than fixed offsets -
# the font's own leading is generous and guessing at it is how the last
# version put the title through the trigrams.
$y = 346 * $u
$sz = Center-Text $g '조선' $fTitle $bTitle $cx $y
$y += $sz.Height * 0.92

$ruleW = 120 * $u
$g.FillRectangle($bGold, [single]($cx - $ruleW / 2), [single]$y, [single]$ruleW, [single](5 * $u))
$y += (5 + 16) * $u

Center-Text $g '국가가 되는 법' $fSub $bMuted $cx $y | Out-Null

$fTitle.Dispose(); $fSub.Dispose(); $bTitle.Dispose(); $bMuted.Dispose(); $bGold.Dispose()
$g.Dispose()

# down to 512
$out = New-Object System.Drawing.Bitmap($N, $N, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g2 = [System.Drawing.Graphics]::FromImage($out)
$g2.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g2.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$ia = New-Object System.Drawing.Imaging.ImageAttributes
$ia.SetWrapMode([System.Drawing.Drawing2D.WrapMode]::TileFlipXY)
$g2.DrawImage($bmp, (New-Object System.Drawing.Rectangle 0, 0, $N, $N), 0, 0, $W, $W,
              [System.Drawing.GraphicsUnit]::Pixel, $ia)
$g2.Dispose(); $ia.Dispose(); $bmp.Dispose()

$outDir = $args[0]
if (-not $outDir) { throw 'usage: make-thumbnail.ps1 <output-dir>' }
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }
$path = Join-Path $outDir 'thumbnail.png'
$out.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
$out.Dispose()
'{0}  ({1:N0} bytes)' -f $path, (Get-Item $path).Length
