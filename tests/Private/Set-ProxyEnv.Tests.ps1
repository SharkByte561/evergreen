<#
    .SYNOPSIS
        Private Pester function tests.
#>
[OutputType()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
param ()

BeforeDiscovery {
}

BeforeAll {
}

Describe -Name "Set-ProxyEnv" {
    BeforeAll {
        InModuleScope Evergreen {
            Set-ProxyEnv -Proxy "proxyserver"
        }
    }

    Context "Tests that Set-ProxyEnv does not throw" {
        It "Should not throw" {
            InModuleScope Evergreen {
                { Set-ProxyEnv -Proxy "proxyserver" } | Should -Not -Throw
            }
        }
    }

    Context "Tests that the proxy server was set" {
        It "Returns True if proxy server is set" {
            InModuleScope Evergreen {
                Test-ProxyEnv | Should -BeTrue
            }
        }
    }
}

AfterAll {
    Remove-Variable -Name "EvergreenProxy" -Scope "Script" -ErrorAction "SilentlyContinue"
}
