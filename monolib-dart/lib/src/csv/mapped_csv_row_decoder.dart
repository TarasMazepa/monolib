import 'dart:async';

class MappedCsvRowDecoder<T> extends StreamTransformerBase<String, T> {
  final T? Function(List<String> row) mapper;

  const MappedCsvRowDecoder(this.mapper);

  @override
  Stream<T> bind(Stream<String> stream) {
    return Stream.multi((controller) {
      String buffer = '';
      bool isInsideDoubleQuotes = false;
      List<String> currentRow = [];
      int previousChar = -1;

      // NEW: Helper to map and filter before hitting the stream
      void emitRow() {
        if (currentRow.isNotEmpty) {
          final mapped = mapper(currentRow);
          if (mapped != null) {
            controller.add(mapped);
          }
          currentRow = [];
        }
      }

      void processBuffer(bool isDone) {
        if (buffer.isEmpty && isDone) {
          if (currentRow.isNotEmpty || previousChar == 44 /* ',' */) {
            if (previousChar == 44) currentRow.add('');
            emitRow(); // Replaced controller.add()
          }
          return;
        }

        int leftIndex = 0;
        int rightIndex = 0;

        int getPrevChar() {
          return rightIndex > 0
              ? buffer.codeUnitAt(rightIndex - 1)
              : previousChar;
        }

        while (rightIndex < buffer.length) {
          final current = buffer.codeUnitAt(rightIndex);

          if (isInsideDoubleQuotes) {
            if (current == 34 /* '"' */) {
              if (rightIndex < buffer.length - 1 &&
                  buffer.codeUnitAt(rightIndex + 1) == 34) {
                rightIndex += 2;
              } else if (rightIndex == buffer.length - 1 && !isDone) {
                break;
              } else {
                isInsideDoubleQuotes = false;
                currentRow.add(
                  buffer.substring(leftIndex, rightIndex).replaceAll('""', '"'),
                );
                leftIndex = rightIndex = rightIndex + 1;
              }
            } else {
              rightIndex++;
            }
          } else {
            if (leftIndex == rightIndex && current == 34) {
              isInsideDoubleQuotes = true;
              leftIndex++;
              rightIndex++;
            } else if (current == 44 /* ',' */) {
              if (leftIndex == rightIndex && getPrevChar() == 34) {
                leftIndex = rightIndex = rightIndex + 1;
              } else {
                currentRow.add(buffer.substring(leftIndex, rightIndex));
                leftIndex = rightIndex = rightIndex + 1;
              }
            } else if (current == 13 /* '\r' */) {
              if (rightIndex < buffer.length - 1 &&
                  buffer.codeUnitAt(rightIndex + 1) == 10 /* '\n' */) {
                if (leftIndex != rightIndex || getPrevChar() == 44) {
                  currentRow.add(buffer.substring(leftIndex, rightIndex));
                }
                emitRow(); // Replaced controller.add()
                leftIndex = rightIndex = rightIndex + 2;
              } else if (rightIndex == buffer.length - 1 && !isDone) {
                break;
              } else {
                rightIndex++;
              }
            } else if (current == 10 /* '\n' */) {
              if (leftIndex != rightIndex || getPrevChar() == 44) {
                currentRow.add(buffer.substring(leftIndex, rightIndex));
              }
              emitRow(); // Replaced controller.add()
              leftIndex = rightIndex = rightIndex + 1;
            } else {
              rightIndex++;
            }
          }
        }

        if (isDone) {
          if (leftIndex < buffer.length || getPrevChar() == 44) {
            if (isInsideDoubleQuotes) {
              currentRow.add(
                buffer.substring(leftIndex, rightIndex).replaceAll('""', '"'),
              );
            } else {
              if (leftIndex == rightIndex && getPrevChar() == 34) {
                // handled
              } else {
                currentRow.add(buffer.substring(leftIndex, rightIndex));
              }
            }
          }
          emitRow(); // Replaced controller.add()
          buffer = '';
        } else {
          if (leftIndex > 0) {
            previousChar = buffer.codeUnitAt(leftIndex - 1);
          }
          buffer = buffer.substring(leftIndex);
        }
      }

      StreamSubscription<String>? subscription;
      subscription = stream.listen(
        (data) {
          buffer += data;
          processBuffer(false);
        },
        onError: controller.addError,
        onDone: () {
          processBuffer(true);
          controller.close();
        },
        cancelOnError: false,
      );

      controller.onPause = subscription.pause;
      controller.onResume = subscription.resume;
      controller.onCancel = subscription.cancel;
    });
  }
}
