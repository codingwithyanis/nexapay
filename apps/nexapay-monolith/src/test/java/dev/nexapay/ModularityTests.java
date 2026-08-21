package dev.nexapay;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.modulith.core.ApplicationModules;

class ModularityTests {

    private static final ApplicationModules MODULES = ApplicationModules.of(NexaPayApplication.class);

    @Test
    void verifiesModularStructure() {
        MODULES.verify();
    }

    @Test
    void discoversAllBoundedContexts() {
        assertThat(MODULES.stream().map(module -> module.getIdentifier().toString()))
                .containsExactlyInAnyOrder(
                        "fraud", "identity", "ledger", "merchant", "notification", "outbox", "payment");
    }
}
