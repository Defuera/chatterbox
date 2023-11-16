import 'dart:math';

import 'package:chatterbox/chatterbox.dart';

/// In the game of 21 Sticks, two players take turns removing 1 to 3 sticks from a total of 21. The player forced to take the last stick loses.
class TwentyOneSticksGameFlow extends Flow {
  @override
  List<StepFactory> get steps => [
        () => TwentyOneSticksGameFlowInitialStep(),
        () => _PlayerTurnStep(),
        () => _BotTurnStep(),
        () => _OnBotWonStep(),
        () => _OnPlayerWonStep(),
      ];
}

class TwentyOneSticksGameFlowInitialStep extends FlowStep {
  @override
  Future<Reaction> handle(MessageContext messageContext, [List<String>? args]) async {
    return ReactionComposed(responses: [
      ReactionResponse(
        text:
            "In the game of 21 Sticks, two players take turns removing 1 to 3 sticks from a total of 21. The player forced to take the last stick loses.",
      ),
      ReactionRedirect(stepUri: (_PlayerTurnStep).toStepUri())
    ]);
  }
}

class _PlayerTurnStep extends FlowStep {
  @override
  Future<Reaction> handle(MessageContext messageContext, [List<String>? args]) async {
    final number = (args?.firstOrNull ?? '21');

    if (number == "1") { //todo pass params for propper winning calculation. params should be [originalNumber, botChoice]
      return ReactionRedirect(stepUri: (_OnBotWonStep).toStepUri());
    } else if (number == "0") {
      return ReactionRedirect(stepUri: (_OnPlayerWonStep).toStepUri());
    }

    return ReactionResponse(
        text: 'There are $number sticks.\n\nHow many sticks do you want to take?',
        // editMessageId: messageContext.editMessageId,
        buttons: [
          InlineButton(title: 'One', nextStepUri: (_BotTurnStep).toStepUri([number, '1'])),
          InlineButton(title: 'Two', nextStepUri: (_BotTurnStep).toStepUri([number, '2'])),
          InlineButton(title: 'Three', nextStepUri: (_BotTurnStep).toStepUri([number, '3'])),
        ].sublist(0, min(3, int.parse(number))));
  }
}

class _BotTurnStep extends FlowStep {
  @override
  Future<Reaction> handle(MessageContext messageContext, [List<String>? args]) async {
    final originalNumber = (args?.firstOrNull ?? '21');
    final userChoice = (args?.elementAtOrNull(1) ?? '1');

    final number = int.parse(originalNumber) - int.parse(userChoice);

    if (number == 1) {
      return ReactionRedirect(stepUri: (_OnPlayerWonStep).toStepUri([originalNumber, userChoice]));
    } else if (number == 0) {
      return ReactionRedirect(stepUri: (_OnBotWonStep).toStepUri([originalNumber, userChoice]));
    }

    final botTurn = Random().nextInt(min(3, number)) + 1;

    return ReactionComposed(responses: [
      ReactionResponse(
        text: 'There are $originalNumber sticks.\n\nYou took out $userChoice sticks.',
        editMessageId: messageContext.editMessageId,
      ),
      ReactionResponse(
        text: 'There are $number sticks.\n\nBot takes out $botTurn sticks.',
      ),
      ReactionRedirect(
        stepUri: (_PlayerTurnStep).toStepUri().appendArgs(['${number - botTurn}']),
      ),
    ]);
  }
}

class _OnBotWonStep extends FlowStep {
  @override
  Future<Reaction> handle(MessageContext messageContext, [List<String>? args]) async {
    final originalNumber = (args?.firstOrNull ?? 'error');
    final userChoice = (args?.elementAtOrNull(1) ?? 'error');

    return ReactionComposed(responses: [
      ReactionResponse(
        text: 'There are $originalNumber sticks.\n\nYou took out $userChoice sticks.',
        editMessageId: messageContext.editMessageId,
      ),
      ReactionResponse(
        text: 'Bot won!',
      ),
    ]);
  }
}

class _OnPlayerWonStep extends FlowStep {
  @override
  Future<Reaction> handle(MessageContext messageContext, [List<String>? args]) async {
    final originalNumber = (args?.firstOrNull ?? 'error');
    final userChoice = (args?.elementAtOrNull(1) ?? 'error');

    return ReactionComposed(responses: [
      ReactionResponse(
        text: 'There are $originalNumber sticks.\n\nYou took out $userChoice sticks.',
        editMessageId: messageContext.editMessageId,
      ),
      ReactionResponse(
        text: 'You won!',
      ),
    ]);
  }
}
