# Copyright (c) 2023, Modular Inc. All rights reserved.
#
# Licensed under the Apache License v2.0 with LLVM Exceptions:
# https://llvm.org/LICENSE.txt
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Usage
# ==========
# ./build-image.ps1 -authKey <your-auth-key>
#
# Make sure docker-desktop currently set on linux container
# CLI option handling code
$DEFAULT_KEY = "5ca1ab1e"
$user_key = $env:user_key
$mojo_ver = "0.3"
$container_engine = "docker"
$extra_cap = ""
while ($args) {
    switch ($args[0]) {
        "-authKey" {
            $user_key = $args[1]
            $args = $args[2..($args.Length - 1)]
        }
        "-usePodman" {
            $container_engine = "podman"
            $extra_cap = "--cap-add SYS_PTRACE"
            $args = $args[1..($args.Length - 1)]
        }
        "-mojoVersion" {
            $mojo_ver = $args[1]
            $args = $args[2..($args.Length - 1)]
        }
        default {
            Write-Host "Unrecognized option $($args[0])"
            $args = $args[1..($args.Length - 1)]
        }
    }
}

function check_options {
    if ($user_key -eq $DEFAULT_KEY) {
        Write-Host "# No auth token specified; use -authKey to specify your token"
        exit 1
    }
}

function build_image {
    check_options
    Write-Host "# Building image with $container_engine..."
    & $container_engine build --no-cache $extra_cap `
        --build-arg AUTH_KEY=$user_key `
        --pull -t "modular/mojo-v$mojo_ver-$(Get-Date -Format 'yyyyMMdd-HHmm')" `
        --file Dockerfile.mojosdk .
}

# Wrap the build in a function
build_image