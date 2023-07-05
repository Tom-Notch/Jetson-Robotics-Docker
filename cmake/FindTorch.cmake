execute_process(
  COMMAND sh -c
          "python3 -c 'import torch; print(torch.utils.cmake_prefix_path)'"
  OUTPUT_VARIABLE TORCH_CMAKE_PREFIX_PATH)

set(CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH}:${TORCH_CMAKE_PREFIX_PATH}")
set(Torch_DIR "${TORCH_CMAKE_PREFIX_PATH}/Torch")

find_package(Torch REQUIRED)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${TORCH_CXX_FLAGS}")

mark_as_advanced(TORCH_LIBRARY TORCH_LIBRARIES TORCH_INCLUDE_DIRS)
