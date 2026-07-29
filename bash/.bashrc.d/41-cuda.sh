# Opt-in CUDA 13.0 toolkit (~/cuda-13.0, user-space install, no system changes).
# Off by default on purpose: the nvcc-less default shell is a canary that
# catches JIT-dependency issues in vLLM/FlashInfer/humming. Run cuda-on to
# enable JIT kernel backends for the current shell; open a new shell to go back.
cuda-on() {
  if [ -n "${CUDA_HOME:-}" ]; then
    echo "CUDA toolkit already on: $CUDA_HOME"
    return 0
  fi
  if [ ! -x "$HOME/cuda-13.0/bin/nvcc" ]; then
    echo "cuda-on: no toolkit at ~/cuda-13.0" >&2
    return 1
  fi
  export CUDA_HOME="$HOME/cuda-13.0"
  export PATH="$CUDA_HOME/bin:$PATH"
  # humming's NVRTC dlopens libnvrtc-builtins via the default search path,
  # so lib64 must be on LD_LIBRARY_PATH; CUDA_HOME alone is not enough.
  export LD_LIBRARY_PATH="$CUDA_HOME/lib64${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
  echo "CUDA toolkit on for this shell (release $("$CUDA_HOME/bin/nvcc" --version | sed -n 's/.*release \([0-9.]*\),.*/\1/p'))"
}
