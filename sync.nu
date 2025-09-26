# sync.nu
def main [file: string] {
    let ext = ($file | path parse | get extension)

    if $ext == "R" {
        # R script → ipynb → qmd
        jupytext --to notebook $file
        let ipynb = ($file | str replace ".R" ".ipynb")
        quarto convert $ipynb --to qmd

    } else if $ext == "py" {
        # Python script → ipynb → qmd
        jupytext --to notebook $file
        let ipynb = ($file | str replace ".py" ".ipynb")
        quarto convert $ipynb --to qmd

    } else if $ext == "qmd" {
        # qmd → ipynb → (R or Python script depending on kernel)
        quarto render $file --to ipynb
        let ipynb = ($file | str replace ".qmd" ".ipynb")

        # detect kernel in qmd metadata
        let kernel = (open $file | lines | where ($it | str contains "jupyter:") | str trim | str replace "jupyter:" "" | str trim)
        if $kernel == "r" {
            jupytext --to R $ipynb
        } else if $kernel == "python3" {
            jupytext --to py:percent $ipynb
        } else {
            print $"Unknown kernel in qmd: ($kernel)"
        }

    } else if $ext == "ipynb" {
        # ipynb → R/Python script + qmd
        jupytext --to R $file
        jupytext --to py:percent $file
        quarto convert $file --to qmd

    } else {
        print $"Unsupported extension: ($ext)"
    }
}
